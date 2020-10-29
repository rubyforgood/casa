require "rails_helper"

RSpec.describe "supervisor volunteer assignment", type: :system do
  let(:organization) { create(:casa_org) }
  let(:supervisor) { create(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }

  describe "case assigned to multiple volunteers" do
    let!(:volunteer_1) { create(:volunteer, display_name: "AAA", casa_org: organization) }
    let!(:volunteer_2) { create(:volunteer, display_name: "BBB", casa_org: organization) }

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

  describe "no volunteers exist" do
    let(:organization) { create(:casa_org) }
    let!(:supervisor) { create(:supervisor, casa_org: organization) }
    let!(:volunteer_1) { create(:volunteer, display_name: "AAA", casa_org: organization) }

    it "does not error out when adding non existent volunteer" do
      sign_in supervisor
      visit edit_supervisor_path(supervisor)
      click_on "Assign Volunteer"
      click_on "Assign Volunteer"
      expect(page).to have_text("There are no active, unassigned volunteers available.")
    end
  end
end
