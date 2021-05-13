require "rails_helper"

RSpec.describe "casa_cases/show", :disable_bullet, type: :system do
  let(:user) { build_stubbed :casa_admin }

  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create :volunteer, display_name: "Andy Dwyer", casa_org: organization }
  let!(:case_assignment) { create(:case_assignment, casa_case: casa_case, volunteer: volunteer) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }

  context "user is an admin" do
    it "redirects to edit volunteer page when volunteer name clicked" do
      sign_in admin
      visit casa_case_path(casa_case.id)

      expect(page).to have_text("Assigned Volunteers:\nAndy Dwyer")
      expect(page).to have_link("Andy Dwyer")

      click_on "Andy Dwyer"

      expect(page).to have_text("Editing Volunteer")
    end
  end

  context "user is a volunteer" do
    it "does not render a link to edit volunteer page" do
      sign_in volunteer
      visit casa_case_path(casa_case.id)

      expect(page).to have_text("Assigned Volunteers:\nAndy Dwyer")
      expect(page).to have_no_link("Andy Dwyer", href: volunteer_path(volunteer.id))
    end
  end
end
