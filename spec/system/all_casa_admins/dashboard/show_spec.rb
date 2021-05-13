require "rails_helper"

RSpec.describe "all_casa_admin/dashboard/show", :disable_bullet, type: :system do
  let(:all_casa_admin) { create(:all_casa_admin) }
  let(:volunteer) { create(:volunteer) }
  let!(:organization) { create(:casa_org) }

  context "when authenticated user" do
    before { sign_in all_casa_admin }

    it "renders AllCasaAdmin dashboard page" do
      visit "/"
      expect(page).to have_text "All CASA Admin"
      expect(page).to have_text organization.name
    end

    it "lets admin navigate to an organization and see casa_admins" do
      ca1 = create(:casa_admin, casa_org: organization)
      ca2 = create(:casa_admin, casa_org: organization)
      vol = create(:volunteer, casa_org: organization)
      sup = create(:supervisor, casa_org: organization)

      visit "/"

      expect(page).to have_text "All CASA Admin"
      expect(page).to have_text organization.name

      click_on organization.name

      expect(page).to have_text "Administrators"
      expect(page).to have_text "New CASA Admin"
      expect(page).to have_text "Back"
      expect(page).to_not have_text vol.email
      expect(page).to_not have_text sup.email
      expect(page).to have_text ca1.email
      expect(page).to have_text ca2.email
    end

    it "has link for new organization" do
      visit "/"
      click_on "New CASA Organization"
      expect(page).to have_text "Create a new CASA Organization"
    end
  end

  context "as any other user" do
    let(:organization) { create(:casa_org) }
    let(:casa_admin) { create(:casa_admin, casa_org: organization) }

    before { sign_in casa_admin }

    it "redirects to root" do
      visit new_all_casa_admins_casa_org_path
      expect(page).to have_text "Volunteers"
      expect(page).to_not have_text "Create a new CASA Organization"
    end
  end

  context "as anonymous user" do
    it "redirects sign in page with warning" do
      visit new_all_casa_admins_casa_org_path
      expect(page).to have_text "You need to sign in before continuing."
    end
  end
end
