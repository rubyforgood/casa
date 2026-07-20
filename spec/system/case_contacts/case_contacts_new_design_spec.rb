require "rails_helper"

# The migrated casa_app case-contacts table (feature flag :new_case_contact_table): a
# bespoke server-rendered table with a disclosure filter panel, per-row expansion, and
# inline row actions (Edit / reminder / Delete). Replaces the jQuery DataTable page.
RSpec.describe "Case contacts new design", type: :system, js: true do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:contact_topic) { create(:contact_topic, casa_org: organization, question: "What was discussed?") }
  let!(:case_contact) do
    create(:case_contact, :active, casa_case: casa_case, notes: "Important follow-up needed")
  end

  before do
    create(:contact_topic_answer,
      case_contact: case_contact,
      contact_topic: contact_topic,
      value: "Youth is doing well in school")
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:new_case_contact_table).and_return(true)
  end

  shared_context "signed in as admin" do
    before do
      sign_in admin
      visit case_contacts_new_design_path
    end
  end

  describe "page shell" do
    include_context "signed in as admin"

    it "renders the case contacts table on the casa_app shell" do
      expect(page).to have_selector("h1", text: "Case contacts")
      expect(page).to have_selector('[data-testid="case_contact-row"]')
    end
  end

  describe "filter panel" do
    let!(:in_person_contact) do
      create(:case_contact, :active, casa_case: casa_case,
        medium_type: CaseContact::IN_PERSON, occurred_at: 5.days.ago)
    end
    let!(:video_contact) do
      create(:case_contact, :active, casa_case: casa_case,
        medium_type: CaseContact::VIDEO, occurred_at: 2.days.ago)
    end
    let!(:draft_contact) do
      create(:case_contact, casa_case: casa_case, status: "started", occurred_at: 1.day.ago)
    end

    before do
      sign_in admin
      visit case_contacts_new_design_path
    end

    it "hides the filter panel by default and opens it on Expand / hide" do
      expect(page).not_to have_css("#cc-filter-panel", visible: true)
      click_button "Expand / hide"
      expect(page).to have_css("#cc-filter-panel", visible: true)
    end

    it "filters by contact medium" do
      in_person_date = I18n.l(in_person_contact.occurred_at, format: :full)
      video_date = I18n.l(video_contact.occurred_at, format: :full)

      click_button "Expand / hide"
      select "In Person", from: "Medium"

      expect(page).to have_text(in_person_date)
      expect(page).not_to have_text(video_date)
    end

    it "filters by date range" do
      old_date = I18n.l(in_person_contact.occurred_at, format: :full)
      recent_date = I18n.l(video_contact.occurred_at, format: :full)

      click_button "Expand / hide"
      execute_script("const el = document.getElementById('occurred_ending_at'); el.value = '#{4.days.ago.to_date}'; el.dispatchEvent(new Event('change', {bubbles: true}))")

      expect(page).to have_text(old_date)
      expect(page).not_to have_text(recent_date)
    end

    it "hides drafts when Hide drafts is checked" do
      draft_date = I18n.l(draft_contact.occurred_at, format: :full)

      click_button "Expand / hide"
      check "Hide drafts"

      expect(page).not_to have_text(draft_date)
    end

    it "resets all filters when Reset filters is clicked" do
      video_date = I18n.l(video_contact.occurred_at, format: :full)

      click_button "Expand / hide"
      select "In Person", from: "Medium"
      expect(page).not_to have_text(video_date)

      click_link "Reset filters"

      expect(page).to have_text(video_date)
    end
  end

  describe "New Case Contact button" do
    include_context "signed in as admin"

    it "is visible to an admin" do
      expect(page).to have_link("New Case Contact", href: new_case_contact_path)
    end

    it "navigates to the new case contact form when clicked as an admin" do
      click_link "New Case Contact"
      expect(page).to have_current_path(%r{/case_contacts/\d+/form/details})
    end

    context "when signed in as a volunteer" do
      let(:volunteer) { create(:volunteer, casa_org: organization) }

      before do
        sign_in volunteer
        visit case_contacts_new_design_path
      end

      it "is visible to a volunteer" do
        expect(page).to have_link("New Case Contact", href: new_case_contact_path)
      end

      it "navigates to the new case contact form when clicked as a volunteer" do
        click_link "New Case Contact"
        expect(page).to have_current_path(%r{/case_contacts/\d+/form/details})
      end
    end
  end

  describe "row expansion" do
    include_context "signed in as admin"

    it "shows the topic answers after clicking the expand toggle" do
      find(".expand-toggle").click

      expect(page).to have_content("What was discussed?")
      expect(page).to have_content("Youth is doing well in school")
    end

    it "shows the notes in the expanded content" do
      find(".expand-toggle").click

      expect(page).to have_content("Additional notes")
      expect(page).to have_content("Important follow-up needed")
    end

    it "hides the expanded content after clicking the toggle again" do
      find(".expand-toggle").click
      expect(page).to have_content("Youth is doing well in school")

      find(".expand-toggle").click
      expect(page).to have_no_content("Youth is doing well in school")
    end
  end

  describe "Edit action" do
    include_context "signed in as admin"

    it "navigates to the edit form" do
      find("[aria-label='Edit contact']").click
      expect(page).to have_current_path(%r{/case_contacts/#{case_contact.id}/form})
    end
  end

  describe "Delete action" do
    include_context "signed in as admin"
    let(:occurred_at_text) { I18n.l(case_contact.occurred_at, format: :full) }

    it "removes the row after confirming the delete dialog" do
      expect(page).to have_text(occurred_at_text)

      find("[aria-label='Delete contact']").click
      expect(page).to have_text("Delete this contact?")
      click_button "Yes, delete"

      expect(page).to have_no_text(occurred_at_text)
    end

    it "leaves the row in place when the delete dialog is cancelled" do
      expect(page).to have_text(occurred_at_text)

      find("[aria-label='Delete contact']").click
      click_button "Cancel"

      expect(page).to have_text(occurred_at_text)
    end
  end

  describe "Set reminder action" do
    include_context "signed in as admin"

    it "creates a followup and shows the reminder indicator after saving" do
      find("[aria-label='Set reminder']").click
      click_button "Save reminder"

      expect(page).to have_css("[aria-label='Reminder set']")
      expect(page).to have_css("[aria-label='Resolve reminder']")
      expect(case_contact.followups.reload).not_to be_empty
    end

    it "does not create a followup when cancelled" do
      find("[aria-label='Set reminder']").click
      click_button "Cancel"

      expect(case_contact.followups.reload).to be_empty
    end
  end

  describe "Resolve reminder action" do
    include_context "signed in as admin"
    let!(:followup) { create(:followup, case_contact: case_contact, status: :requested, creator: admin) }

    before { visit case_contacts_new_design_path }

    it "resolves the followup and swaps back to Set reminder" do
      expect(page).to have_css("[aria-label='Reminder set']")

      find("[aria-label='Resolve reminder']").click

      expect(page).to have_css("[aria-label='Set reminder']")
      expect(page).to have_no_css("[aria-label='Reminder set']")
      expect(followup.reload.status).to eq("resolved")
    end
  end

  describe "permission states" do
    let(:volunteer) { create(:volunteer, casa_org: organization) }
    let(:volunteer_case) { create(:casa_case, casa_org: organization) }
    let!(:active_contact) { create(:case_contact, :active, casa_case: volunteer_case, creator: volunteer, occurred_at: 5.days.ago) }
    let!(:draft_contact) { create(:case_contact, casa_case: volunteer_case, creator: volunteer, status: "started", occurred_at: 10.days.ago) }

    before do
      sign_in volunteer
      visit case_contacts_new_design_path
    end

    it "lets a volunteer edit their own active contact" do
      within("tr", text: I18n.l(active_contact.occurred_at, format: :full)) do
        expect(page).to have_css("[aria-label='Edit contact']")
      end
    end

    it "does not offer delete for a volunteer's own active contact" do
      within("tr", text: I18n.l(active_contact.occurred_at, format: :full)) do
        expect(page).to have_no_css("[aria-label='Delete contact']")
      end
    end

    it "offers delete for a volunteer's own draft contact" do
      within("tr", text: I18n.l(draft_contact.occurred_at, format: :full)) do
        expect(page).to have_css("[aria-label='Delete contact']")
      end
    end
  end
end
