require "rails_helper"

RSpec.describe "case_contacts/edit", type: :system do
  let(:organization) { build(:casa_org) }
  let(:casa_case) { create(:casa_case, :with_case_assignments, casa_org: organization) }
  let!(:case_contact) { create(:case_contact, duration_minutes: 105, casa_case: casa_case) }

  context "when admin" do
    let(:admin) { create(:casa_admin, casa_org: organization) }

    it "admin successfully edits case contact", js: true do
      sign_in admin

      visit edit_case_contact_path(case_contact)

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "Letter")
      complete_notes_page
      fill_in_expenses_page

      click_on "Submit"

      case_contact.reload
      expect(page).to have_text "Case contact created at #{case_contact.created_at.strftime("%-I:%-M %p on %m-%e-%Y")}, was successfully updated."
      expect(case_contact.casa_case_id).to eq casa_case.id
      expect(case_contact.duration_minutes).to eq 105
      expect(case_contact.medium_type).to eq "letter"
      expect(case_contact.contact_made).to eq true
    end

    it "admin successfully edits case contact with mileage reimbursement", js: true do
      casa_case = create(:casa_case, :with_one_case_assignment, casa_org: organization)
      case_contact = create(:case_contact, duration_minutes: 105, casa_case: casa_case)
      sign_in admin

      visit edit_case_contact_path(case_contact)

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "In Person", hours: 1, minutes: 45, occurred_on: "04/04/2020")
      complete_notes_page
      fill_in_expenses_page(miles: 10, want_reimbursement: true, address: "123 str")

      click_on "Submit"
      case_contact.reload
      expect(page).to have_text "Case contact created at #{case_contact.created_at.strftime("%-I:%-M %p on %m-%e-%Y")}, was successfully updated."
      expect(case_contact.casa_case.volunteers[0].address.content).to eq "123 str"
      expect(case_contact.casa_case_id).to eq casa_case.id
      expect(case_contact.duration_minutes).to eq 105
      expect(case_contact.medium_type).to eq "in-person"
      expect(case_contact.contact_made).to eq true
    end

    it "admin fails to edit volunteer address for case contact with mileage reimbursement", js: true do
      sign_in admin

      visit edit_case_contact_path(case_contact)

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "In Person", hours: 1, minutes: 45, occurred_on: "04/04/2020")
      complete_notes_page

      expect(find("#case_contact_volunteer_address").value)
        .to eq("There are two or more volunteers assigned to this case and \
you are trying to set the address for both of them. This is not currently possible.")
    end

    context "is part of a different organization" do
      let(:other_organization) { build(:casa_org) }
      let(:admin) { create(:casa_admin, casa_org: other_organization) }

      it "fails across organizations" do
        sign_in admin

        visit edit_case_contact_path(case_contact)
        expect(current_path).to eq supervisors_path
      end
    end
  end

  context "volunteer user" do
    let(:volunteer) { create(:volunteer, casa_org: organization) }
    let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

    it "is successful", js: true do
      case_contact = create(:case_contact, duration_minutes: 105, casa_case: casa_case, creator: volunteer)
      sign_in volunteer
      visit edit_case_contact_path(case_contact)

      complete_details_page(contact_made: true, medium: "Letter")
      complete_notes_page
      fill_in_expenses_page

      click_on "Submit"

      case_contact.reload
      expect(page).to have_text "Case contact created at #{case_contact.created_at.strftime("%-I:%-M %p on %m-%e-%Y")}, was successfully updated."
      expect(case_contact.casa_case_id).to eq casa_case.id
      expect(case_contact.duration_minutes).to eq 105
      expect(case_contact.medium_type).to eq "letter"
      expect(case_contact.contact_made).to eq true
    end

    it "is successful with mileage reimbursement on", js: true do
      case_contact = create(:case_contact, duration_minutes: 105, casa_case: casa_case, creator: volunteer)
      sign_in volunteer
      visit edit_case_contact_path(case_contact)

      complete_details_page(contact_made: true, medium: "In Person", hours: 1, minutes: 45, occurred_on: "04/04/2020")
      complete_notes_page
      fill_in_expenses_page(miles: 10, want_reimbursement: true, address: "123 str")

      click_on "Submit"

      case_contact.reload
      volunteer.reload
      expect(page).to have_text "Case contact created at #{case_contact.created_at.strftime("%-I:%-M %p on %m-%e-%Y")}, was successfully updated."
      expect(volunteer.address.content).to eq "123 str"
      expect(case_contact.casa_case_id).to eq casa_case.id
      expect(case_contact.duration_minutes).to eq 105
      expect(case_contact.medium_type).to eq "in-person"
      expect(case_contact.contact_made).to eq true
    end

    it "autosaves notes", js: true do
      case_contact = create(:case_contact, duration_minutes: 105, casa_case: casa_case, creator: volunteer, notes: "Hello from the other side")
      sign_in volunteer
      visit edit_case_contact_path(case_contact)

      complete_details_page(contact_made: true)
      expect(CaseContact.last.notes).not_to eq "Hello world"

      complete_notes_page(notes: "Hello world", click_continue: false)

      within 'div[data-controller="autosave"]' do
        find('small[data-autosave-target="alert"]', text: "Saved!")
      end

      expect(CaseContact.last.notes).to eq "Hello world"
    end

    context "when 'Create Another' option is checked" do
      it "redirects to new contact with the same draft_case_ids", js: true do
        case_contact = create(:case_contact, duration_minutes: 105, casa_case: casa_case, creator: volunteer)
        sign_in volunteer
        visit edit_case_contact_path(case_contact)

        complete_details_page(contact_made: true, medium: "Letter")
        complete_notes_page
        fill_in_expenses_page

        check "Create Another"
        expect { click_on "Submit" }.to change { CaseContact.count }.by(1)

        expect(page).to have_text "Step 1 of 3"
        expect(page).to have_text casa_case.case_number
      end
    end
  end
end
