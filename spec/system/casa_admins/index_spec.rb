require "rails_helper"

RSpec.describe "casa_admins/index", :disable_bullet, type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  it "displays other admins within the same CASA organization" do
    admin2 = create(:casa_admin, email: "Jon@org.com", casa_org: organization)
    admin3 = create(:casa_admin, email: "Bon@org.com", casa_org: organization)
    different_org_admin = create(:casa_admin, email: "Jovi@something.else", casa_org: create(:casa_org))
    supervisor = create(:supervisor, email: "super@visor.com", casa_org: organization)
    volunteer = create(:volunteer, email: "volun@tear.com", casa_org: organization)

    sign_in admin
    visit casa_admins_path

    within "#admins" do
      expect(page).to have_content(admin2.email)
      expect(page).to have_content(admin3.email)
      expect(page).to have_no_content(different_org_admin.email)
      expect(page).to have_no_content(supervisor.email)
      expect(page).to have_no_content(volunteer.email)
    end
  end

  it "displays a deactivated tag for inactive admins" do
    inactive_admin = create(:casa_admin, :inactive, casa_org: organization)

    sign_in admin
    visit casa_admins_path

    within "#admins" do
      expect(page).to have_content(inactive_admin.email)
      expect(page).to have_content("Deactivated")
    end
  end
end
