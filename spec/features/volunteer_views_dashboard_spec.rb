require "rails_helper"

RSpec.describe "volunteer views dashboard", type: :feature do
  it "sees only case contacts created by the volunteer" do
    volunteer = create(:user, :volunteer)
    case_assignment = create(:case_assignment, volunteer: volunteer)
    case_contact = create(:case_contact, casa_case: case_assignment.casa_case)
    sign_in volunteer
    visit root_path
    expect(page).to have_text(case_assignment.casa_case.case_number)
  end
end
