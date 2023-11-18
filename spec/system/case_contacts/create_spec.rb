require "rails_helper"

RSpec.describe "case_contacts/create", type: :system do
  let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }
  let(:casa_case) { volunteer.casa_cases.first }

  context "redirects to where new case contact started from" do
    before do
      sign_in volunteer
    end

    it "when /case_contacts" do
      visit case_contacts_path

      click_on "New Case Contact"
      complete_form(casa_case)
      click_on "Submit"

      expect(page).to have_current_path(case_contacts_path)
    end

    it "when /case_contacts?casa_case_id=ID" do
      visit case_contacts_path(casa_case_id: casa_case.id)

      click_on "New Case Contact"
      complete_form(casa_case)
      click_on "Submit"

      expect(page).to have_current_path(case_contacts_path(casa_case_id: casa_case.id))
    end

    it "when /casa_cases/CASE_NUMBER" do
      visit casa_case_path(casa_case)

      click_on "New Case Contact"
      complete_form(casa_case)
      click_on "Submit"

      expect(page).to have_current_path(casa_case_path(casa_case))
    end
  end
end

def complete_form(casa_case)
  within ".casa-case-scroll" do
    check casa_case.case_number
  end

  within "#contact-type-form" do
    check casa_case.casa_org.contact_type_groups.first.contact_types.first.name
  end

  within "#enter-contact-details" do
    choose "Yes"
  end

  choose "In Person"
  fill_in "case_contact_duration_hours", with: "1"
  fill_in "case_contact_duration_minutes", with: "45"
end
