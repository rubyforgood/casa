require "rails_helper"

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

  describe "columns panel" do
    include_context "signed in as admin"

    it "shows a Columns button in the toolbar" do
      expect(page).to have_button("Columns")
    end

    it "shows a visible count badge on the Columns button" do
      expect(page).to have_button(text: /Columns\s*\(6\/6\)/)
    end

    it "hides the columns panel by default" do
      expect(page).not_to have_css("#cc-columns-panel", visible: true)
    end

    it "opens the columns panel when the Columns button is clicked" do
      click_button "Columns"
      expect(page).to have_css("#cc-columns-panel", visible: true)
    end

    it "closes the columns panel when the Columns button is clicked again" do
      click_button "Columns"
      click_button "Columns"
      expect(page).not_to have_css("#cc-columns-panel", visible: true)
    end

    it "hides a column when its toggle is switched off and Update View is clicked" do
      click_button "Columns"
      uncheck "Medium"
      click_button "Update View"

      expect(page).not_to have_css("th", text: "Medium")
    end

    it "shows a column again when its toggle is switched back on and Update View is clicked" do
      click_button "Columns"
      uncheck "Medium"
      click_button "Update View"

      click_button "Columns"
      check "Medium"
      click_button "Update View"

      expect(page).to have_css("th", text: "Medium")
    end

    it "updates the badge count when a column is hidden" do
      click_button "Columns"
      uncheck "Medium"
      click_button "Update View"

      expect(page).to have_button(text: /Columns\s*\(5\/6\)/)
    end

    it "shows all columns and closes the panel when Show All is clicked" do
      click_button "Columns"
      uncheck "Medium"
      uncheck "Topics"
      click_button "Update View"

      click_button "Columns"
      click_button "Show All"

      expect(page).to have_css("th", text: "Medium")
      expect(page).to have_css("th", text: "Topics")
      expect(page).to have_button(text: /Columns\s*\(6\/6\)/)
      expect(page).not_to have_css("#cc-columns-panel", visible: true)
    end

    it "lists all 6 toggleable columns with toggle switches, all on by default" do
      %w[Relationship Medium Contacted Topics Draft].each do |label|
        expect(page).to have_css("#cc-columns-panel .form-switch", text: label, visible: :all)
        expect(page).to have_field(label, checked: true, visible: :all)
      end
      expect(page).to have_css("#cc-columns-panel .form-switch", text: "Created By", visible: :all)
      expect(page).to have_field("Created By", checked: true, visible: :all)
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

    it "shows the Filter button" do
      expect(page).to have_button("Filter")
    end

    it "hides the filter panel by default" do
      expect(page).not_to have_css("#cc-filter-panel", visible: true)
    end

    it "opens the filter panel when the Filter button is clicked" do
      click_button "Filter"
      expect(page).to have_css("#cc-filter-panel", visible: true)
    end

    it "closes the filter panel when the Filter button is clicked again" do
      click_button "Filter"
      click_button "Filter"
      expect(page).not_to have_css("#cc-filter-panel", visible: true)
    end

    it "filters by contact medium" do
      in_person_date = I18n.l(in_person_contact.occurred_at, format: :full)
      video_date = I18n.l(video_contact.occurred_at, format: :full)

      click_button "Filter"
      select "In Person", from: "cc-filter-medium"
      click_button "Apply Filters"

      expect(page).to have_text(in_person_date)
      expect(page).not_to have_text(video_date)
    end

    it "filters by date range" do
      old_date = I18n.l(in_person_contact.occurred_at, format: :full)
      recent_date = I18n.l(video_contact.occurred_at, format: :full)

      click_button "Filter"
      execute_script("document.getElementById('cc-filter-occurred-ending-at').value = '#{4.days.ago.to_date}'")
      click_button "Apply Filters"

      expect(page).to have_text(old_date)
      expect(page).not_to have_text(recent_date)
    end

    it "hides drafts when the hide drafts checkbox is checked" do
      draft_date = I18n.l(draft_contact.occurred_at, format: :full)

      click_button "Filter"
      check "cc-filter-no-drafts"
      click_button "Apply Filters"

      expect(page).not_to have_text(draft_date)
    end

    it "resets all filters when the Reset button is clicked" do
      in_person_date = I18n.l(in_person_contact.occurred_at, format: :full)
      video_date = I18n.l(video_contact.occurred_at, format: :full)

      click_button "Filter"
      select "In Person", from: "cc-filter-medium"
      click_button "Apply Filters"
      expect(page).not_to have_text(video_date)

      click_button "Filter"
      click_button "Reset"

      expect(page).to have_text(in_person_date)
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
    it "shows the expanded content after clicking the chevron" do
      find(".expand-toggle").click

      expect(page).to have_content("What was discussed?")
      expect(page).to have_content("Youth is doing well in school")
    end

    it "shows notes in the expanded content" do
      find(".expand-toggle").click

      expect(page).to have_content("Additional Notes")
      expect(page).to have_content("Important follow-up needed")
    end

    it "hides the expanded content after clicking the chevron again" do
      find(".expand-toggle").click
      expect(page).to have_content("Youth is doing well in school")

      find(".expand-toggle").click
      expect(page).to have_no_content("Youth is doing well in school")
    end
  end

  describe "action menu" do
    include_context "signed in as admin"
    it "opens the dropdown when the ellipsis button is clicked" do
      find(".cc-ellipsis-toggle").click

      expect(page).to have_css(".dropdown-menu.show")
    end

    it "shows Edit in the menu" do
      find(".cc-ellipsis-toggle").click

      expect(page).to have_text("Edit")
    end

    it "shows Delete in the menu" do
      find(".cc-ellipsis-toggle").click

      expect(page).to have_text("Delete")
    end

    it "shows Set Reminder when no followup exists" do
      find(".cc-ellipsis-toggle").click

      expect(page).to have_text("Set Reminder")
      expect(page).to have_no_text("Resolve Reminder")
    end

    it "shows Resolve Reminder when a requested followup exists" do
      create(:followup, case_contact: case_contact, status: :requested, creator: admin)
      visit case_contacts_new_design_path

      find(".cc-ellipsis-toggle").click

      expect(page).to have_text("Resolve Reminder")
      expect(page).to have_no_text("Set Reminder")
    end

    it "closes the dropdown when clicking outside" do
      find(".cc-ellipsis-toggle").click
      expect(page).to have_css(".dropdown-menu.show")

      find("h1").click
      expect(page).to have_no_css(".dropdown-menu.show")
    end
  end

  describe "Edit action" do
    include_context "signed in as admin"
    it "navigates to the edit form when Edit is clicked" do
      find(".cc-ellipsis-toggle").click
      click_link "Edit"

      expect(page).to have_current_path(/case_contacts\/#{case_contact.id}\/form/)
    end
  end

  describe "Delete action" do
    include_context "signed in as admin"
    let(:occurred_at_text) { I18n.l(case_contact.occurred_at, format: :full) }

    it "removes the row after confirming the delete dialog" do
      expect(page).to have_text(occurred_at_text)

      find(".cc-ellipsis-toggle").click
      find(".cc-delete-action").click
      click_button "Delete"

      expect(page).to have_no_text(occurred_at_text)
    end

    it "leaves the row in place when the delete dialog is cancelled" do
      expect(page).to have_text(occurred_at_text)

      find(".cc-ellipsis-toggle").click
      find(".cc-delete-action").click
      click_button "Cancel"

      expect(page).to have_text(occurred_at_text)
    end
  end

  describe "Set Reminder action" do
    include_context "signed in as admin"
    it "creates a followup and shows Resolve Reminder in the menu after confirming" do
      find(".cc-ellipsis-toggle").click
      find(".cc-set-reminder-action").click
      click_button "Confirm"

      expect(page).to have_css("i.fas.fa-bell:not([style])")

      find(".cc-ellipsis-toggle").click
      expect(page).to have_text("Resolve Reminder")
      expect(page).to have_no_text("Set Reminder")
    end

    it "does not create a followup when cancelled" do
      find(".cc-ellipsis-toggle").click
      find(".cc-set-reminder-action").click
      click_button "Cancel"

      expect(case_contact.followups.reload).to be_empty
    end
  end

  describe "Resolve Reminder action" do
    include_context "signed in as admin"

    let!(:followup) { create(:followup, case_contact: case_contact, status: :requested, creator: admin) }

    before { visit case_contacts_new_design_path }

    it "resolves the followup and shows Set Reminder in the menu afterwards" do
      find(".cc-ellipsis-toggle").click
      find(".cc-resolve-reminder-action").click

      expect(page).to have_css("i.fas.fa-bell[style*='opacity']")

      find(".cc-ellipsis-toggle").click
      expect(page).to have_text("Set Reminder")
      expect(page).to have_no_text("Resolve Reminder")
    end

    it "marks the followup as resolved" do
      find(".cc-ellipsis-toggle").click
      find(".cc-resolve-reminder-action").click

      # Wait for reload to confirm the AJAX completed before checking DB
      expect(page).to have_css("i.fas.fa-bell[style*='opacity']")

      expect(followup.reload.status).to eq("resolved")
    end
  end

  describe "permission states" do
    let(:volunteer) { create(:volunteer, casa_org: organization) }
    let(:casa_case_for_volunteer) { create(:casa_case, casa_org: organization) }
    let!(:active_contact) { create(:case_contact, :active, casa_case: casa_case_for_volunteer, creator: volunteer, occurred_at: 5.days.ago) }
    let!(:draft_contact) { create(:case_contact, casa_case: casa_case_for_volunteer, creator: volunteer, status: "started", occurred_at: 10.days.ago) }

    before do
      sign_in volunteer
      visit case_contacts_new_design_path
    end

    it "shows Delete as disabled for an active contact" do
      find("#cc-actions-btn-#{active_contact.id}").click
      expect(page).to have_css(".dropdown-menu[aria-labelledby='cc-actions-btn-#{active_contact.id}'].show")
      expect(page).to have_css(".dropdown-menu[aria-labelledby='cc-actions-btn-#{active_contact.id}'] button.dropdown-item.disabled", text: "Delete")
    end

    it "shows Delete as enabled for a draft contact" do
      find("#cc-actions-btn-#{draft_contact.id}").click
      expect(page).to have_css(".dropdown-menu[aria-labelledby='cc-actions-btn-#{draft_contact.id}'].show")
      expect(page).to have_css(".dropdown-menu[aria-labelledby='cc-actions-btn-#{draft_contact.id}'] button.cc-delete-action", text: "Delete")
    end
  end
end
