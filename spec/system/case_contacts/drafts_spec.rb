require "rails_helper"

RSpec.describe "case_contacts/drafts", type: :system do
  let(:organization) { build(:casa_org) }
  let(:admin) { build(:casa_admin, casa_org: organization) }

  context "with case contacts" do
    let!(:casa_case) { build(:casa_case, casa_org: organization) }
    let!(:other_org_case) { build(:case_contact, notes: "NOTE_A") }
    let!(:past_contact) { build(:case_contact, casa_case: casa_case, occurred_at: 3.weeks.ago, notes: "NOTE_B") }
    let!(:past_contact_draft) { create(:case_contact, :started_status, casa_case: casa_case, occurred_at: 3.weeks.ago, notes: "NOTE_C") }
    let!(:recent_contact) { build(:case_contact, casa_case: casa_case, occurred_at: 3.days.ago, notes: "NOTE_D") }
    let!(:recent_contact_draft) { create(:case_contact, :started_status, casa_case: casa_case, occurred_at: 3.days.ago, notes: "NOTE_E") }

    it "shows only same orgs drafts" do
      sign_in admin

      visit case_contacts_drafts_path

      expect(page).to have_content("NOTE_C")
      expect(page).to have_content("NOTE_E")

      expect(page).not_to have_content("NOTE_A")
      expect(page).not_to have_content("NOTE_B")
      expect(page).not_to have_content("NOTE_D")
    end
  end

  context "as a volunteer" do
    let(:organization) { build(:casa_org) }
    let(:volunteer) { create(:volunteer, casa_org: organization) }
    let(:casa_case) { create(:casa_case, casa_org: organization) }
    let!(:my_draft) do
      create(:case_contact, :started_status, creator: volunteer, casa_case: nil,
        draft_case_ids: [casa_case.id], notes: "MY DRAFT NOTE")
    end
    let!(:other_volunteers_draft) { create(:case_contact, :started_status, notes: "OTHER DRAFT NOTE") }
    let!(:my_active_contact) do
      create(:case_contact, creator: volunteer, casa_case: casa_case, notes: "ACTIVE NOTE")
    end

    it "shows only the volunteer's own drafts, with their case, last edit and notes preview" do
      sign_in volunteer

      visit case_contacts_drafts_path

      expect(page).to have_content("MY DRAFT NOTE")
      expect(page).to have_content(casa_case.case_number)
      expect(page).to have_content("Last edited")

      expect(page).not_to have_content("OTHER DRAFT NOTE")
      expect(page).not_to have_content("ACTIVE NOTE")
    end

    it "continues a draft into the form wizard" do
      sign_in volunteer

      visit case_contacts_drafts_path
      click_on "Continue"

      expect(page).to have_current_path(case_contact_form_path(:details, case_contact_id: my_draft.id))
    end

    it "discards a draft after confirmation", :js do
      sign_in volunteer

      visit case_contacts_drafts_path
      click_on "Discard"
      within("dialog") { click_button "Discard draft" }

      expect(page).to have_text("Draft discarded.")
      expect(page).not_to have_content("MY DRAFT NOTE")
      expect { my_draft.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "paginates the list" do
      # Distinct edit times so the newest-first order is stable across same-second creates.
      20.times do |i|
        create(:case_contact, :started_status, creator: volunteer, casa_case: nil,
          draft_case_ids: [casa_case.id], notes: "PAGINATION DRAFT", updated_at: (i + 1).minutes.ago)
      end

      sign_in volunteer

      visit case_contacts_drafts_path
      expect(page).to have_content("MY DRAFT NOTE") # newest edit first
      expect(page).to have_content("PAGINATION DRAFT", count: 19)
      expect(page).to have_text("Showing 1–20 of 21")

      find('a[aria-label="Page 2"]').click
      expect(page).to have_content("PAGINATION DRAFT", count: 1)
    end

    it "shows the unfinished-drafts notice on the case contacts page and links to the list" do
      sign_in volunteer

      visit case_contacts_path
      expect(page).to have_text("You have 1 unfinished case contact")

      click_on "Review drafts"
      expect(page).to have_current_path(case_contacts_drafts_path)
    end

    it "shows no unfinished-drafts notice for admins" do
      sign_in admin

      visit case_contacts_path

      expect(page).not_to have_text("unfinished case contact")
    end

    context "on the dashboard" do
      let(:casa_case_two) { create(:casa_case, casa_org: organization) }

      # A volunteer with exactly one active case is redirected straight to the new-contact
      # form, so two assignments are needed for the dashboard to render at all.
      before do
        create(:case_assignment, volunteer: volunteer, casa_case: casa_case)
        create(:case_assignment, volunteer: volunteer, casa_case: casa_case_two)
      end

      it "shows the unfinished-drafts notice with a link to the list" do
        sign_in volunteer

        visit authenticated_user_root_path

        expect(page).to have_text("You have 1 unfinished case contact")
        expect(page).to have_link("Review drafts", href: case_contacts_drafts_path)
      end
    end
  end

  context "as a volunteer with no drafts" do
    let(:organization) { build(:casa_org) }
    let(:volunteer) { create(:volunteer, casa_org: organization) }

    it "shows an empty list" do
      sign_in volunteer

      visit case_contacts_drafts_path

      expect(page).to have_content("No unfinished case contacts.")
    end
  end
end
