require "rails_helper"

RSpec.describe "Volunteer logs in and clicks 'Case Contacts' ", type: :system do
  it "sees all case contacts for their case" do
    volunteer = create(:volunteer)
    casa_case = create(:casa_case, casa_org: volunteer.casa_org)
    case_assignment = create(:case_assignment, volunteer: volunteer, casa_case: casa_case)
    case_contact = create(:case_contact, casa_case: case_assignment.casa_case, miles_driven: 98)

    sign_in volunteer
    visit "/case_contacts"
    expect(page).to have_content("Case Contacts")
    expect(page).to have_text(case_assignment.casa_case.case_number)
    expect(page).to have_text(case_contact.miles_driven)
  end
end
