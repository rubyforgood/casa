require "rails_helper"

RSpec.describe "volunteer assigned to multiple cases", type: :system do
  let!(:supervisor) { create(:casa_admin) }
  let!(:volunteer) { create(:volunteer, display_name: 'AAA') }
  let!(:casa_case_1) { create(:casa_case, case_number: 'CINA1') }
  let!(:casa_case_2) { create(:casa_case, case_number: 'CINA2') }

  it "supervisor assigns multiple cases to the same volunteer" do
    sign_in supervisor
    visit edit_volunteer_path(volunteer.id)

    select casa_case_1.case_number, from: "Select a Case"
    click_on "Assign Case"
    expect(page).to have_text("Volunteer assigned to case")
    expect(page).to have_text(casa_case_1.case_number)

    select casa_case_2.case_number, from: "Select a Case"
    click_on "Assign Case"
    expect(page).to have_text("Volunteer assigned to case")
    expect(page).to have_text(casa_case_2.case_number)
  end
end
