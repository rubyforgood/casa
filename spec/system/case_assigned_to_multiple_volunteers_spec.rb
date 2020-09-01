require "rails_helper"

RSpec.describe "case assigned to multiple volunteers", type: :system do
  let!(:supervisor) { create(:casa_admin) }
  let!(:volunteer_1) { create(:volunteer, display_name: 'AAA') }
  let!(:volunteer_2) { create(:volunteer, display_name: 'BBB') }
  let!(:casa_case) { create(:casa_case) }

  it "supervisor assigns multiple volunteers to the same case" do
    sign_in supervisor
    visit edit_casa_case_path(casa_case.id)

    select volunteer_1.display_name, from: "Select a Volunteer"
    click_on "Assign Volunteer"
    expect(page).to have_text("Volunteer assigned to case")
    expect(page).to have_text(volunteer_1.display_name)

    select volunteer_2.display_name, from: "Select a Volunteer"
    click_on "Assign Volunteer"
    expect(page).to have_text("Volunteer assigned to case")
    expect(page).to have_text(volunteer_2.display_name)
  end
end
