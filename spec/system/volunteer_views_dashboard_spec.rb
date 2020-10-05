require "rails_helper"

RSpec.describe "volunteer views dashboard", type: :system do
  it "sees all their casa cases" do
    volunteer = create(:volunteer)
    casa_case_1 = create(:casa_case, casa_org: volunteer.casa_org)
    casa_case_2 = create(:casa_case, casa_org: volunteer.casa_org)
    casa_case_3 = create(:casa_case, casa_org: volunteer.casa_org)
    create(:case_assignment, volunteer: volunteer, casa_case: casa_case_1)
    create(:case_assignment, volunteer: volunteer, casa_case: casa_case_2)


    sign_in volunteer
    visit root_path 
    expect(page).to have_text("My Cases")
    expect(page).to have_text(casa_case_1.case_number)
    expect(page).to have_text(casa_case_2.case_number)
    expect(page).not_to have_text(casa_case_3.case_number)
  end
end
