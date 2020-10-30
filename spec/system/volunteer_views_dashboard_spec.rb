require "rails_helper"

RSpec.describe "volunteer views dashboard", type: :system do
  let(:volunteer) { create(:volunteer) }

  before do
    sign_in volunteer
  end

  it "sees all their casa cases" do
    casa_case_1 = create(:casa_case, casa_org: volunteer.casa_org, case_number: "SLAVA-1")
    casa_case_2 = create(:casa_case, casa_org: volunteer.casa_org, case_number: "SLAVA-2")
    casa_case_3 = create(:casa_case, casa_org: volunteer.casa_org, case_number: "SLAVA-3")
    create(:case_assignment, volunteer: volunteer, casa_case: casa_case_1)
    create(:case_assignment, volunteer: volunteer, casa_case: casa_case_2)

    visit root_path
    expect(page).to have_text("My Cases")
    expect(page).to have_text(casa_case_1.case_number)
    expect(page).to have_text(casa_case_2.case_number)
    expect(page).not_to have_text(casa_case_3.case_number)
  end

  it "displays 'No active cases' when they don't have any assignments" do
    visit root_path
    expect(page).to have_text("My Cases")
    expect(page).to have_text("No active cases")
  end
end
