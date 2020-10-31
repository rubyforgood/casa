require "rails_helper"

RSpec.describe "volunteer assigned to multiple cases", type: :system do
  let(:organization) { create(:casa_org) }
  let(:supervisor) { create(:casa_admin, casa_org: organization) }

  describe "innactive case visibility" do
    let!(:active_casa_case) { create(:casa_case, casa_org: organization, case_number: "ACTIVE") }
    let!(:inactive_casa_case) { create(:casa_case, casa_org: organization, active: false, case_number: "INACTIVE") }
    let!(:volunteer) { create(:volunteer, display_name: "Awesome Volunteer", casa_org: organization) }

    it "supervisor does not have inactive cases as an option to assign to a volunteer" do
      sign_in supervisor
      visit edit_volunteer_path(volunteer)

      expect(page).to have_content(active_casa_case.case_number)
      expect(page).not_to have_content(inactive_casa_case.case_number)
    end
  end
end
