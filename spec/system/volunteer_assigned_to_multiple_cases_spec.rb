require "rails_helper"

RSpec.describe "volunteer assigned to multiple cases", type: :system do
  let(:casa_org) { create(:casa_org) }
  let!(:supervisor) { create(:casa_admin, casa_org: casa_org) }
  let!(:volunteer) { create(:volunteer, casa_org: casa_org, display_name: "AAA") }
  let!(:casa_case_1) { create(:casa_case, casa_org: casa_org, case_number: "CINA1") }
  let!(:casa_case_2) { create(:casa_case, casa_org: casa_org, case_number: "CINA2") }

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
