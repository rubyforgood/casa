require "rails_helper"

RSpec.describe "volunteer views dashboard", type: :system do
  xit "sees all case contacts for their case" do
    volunteer = create(:volunteer)
    casa_case = create(:casa_case, casa_org: volunteer.casa_org)
    case_assignment = create(:case_assignment, volunteer: volunteer, casa_case: casa_case)
    case_contact = create(:case_contact, casa_case: case_assignment.casa_case, miles_driven: 98)
    case_contact_for_other_case = create(:case_contact, miles_driven: 777)

    sign_in volunteer
    visit root_path
    expect(page).to have_text(case_assignment.casa_case.case_number)
    expect(page).to have_text(case_contact.miles_driven)
    expect(page).not_to have_text(case_contact_for_other_case.miles_driven)
  end
end
