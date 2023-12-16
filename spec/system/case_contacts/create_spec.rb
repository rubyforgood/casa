require "rails_helper"

RSpec.describe "case_contacts/create", type: :system, js: true do
  let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }
  let(:casa_case) { volunteer.casa_cases.first }

  context "redirects to where new case contact started from" do
    before do
      sign_in volunteer
    end

    it "when /case_contacts" do
      visit case_contacts_path

      click_on "New Case Contact"
      complete_details_page(case_numbers: [casa_case.case_number], medium: "In Person", contact_made: true, hours: 1, minutes: 45)
      complete_notes_page
      fill_in_expenses_page
      click_on "Submit"

      expect(page).to have_text "Case contact successfully created"
    end

    it "when /case_contacts?casa_case_id=ID" do
      visit case_contacts_path(casa_case_id: casa_case.id)

      click_on "New Case Contact"
      complete_details_page(case_numbers: [casa_case.case_number], medium: "In Person", contact_made: true, hours: 1, minutes: 45)
      complete_notes_page
      fill_in_expenses_page
      click_on "Submit"

      expect(page).to have_text "Case contact successfully created"
    end

    it "when /casa_cases/CASE_NUMBER" do
      visit casa_case_path(casa_case)

      click_on "New Case Contact"
      complete_details_page(case_numbers: [casa_case.case_number], medium: "In Person", contact_made: true, hours: 1, minutes: 45)
      complete_notes_page
      fill_in_expenses_page
      click_on "Submit"

      expect(page).to have_text "Case contact successfully created"
    end
  end
end
