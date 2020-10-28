require "rails_helper"

RSpec.describe "all casa admins with casa orgs", type: :system do
  context "as an all casa admin" do
    let(:all_casa_admin) { create(:all_casa_admin, email: "theexample@example.com") }
    let(:current_organization) { create(:casa_org) }

    before { sign_in all_casa_admin }

    it "lets admin navigate to an organization and see casa_admins" do
      ca1 = create(:casa_admin, casa_org: current_organization)
      ca2 = create(:casa_admin, casa_org: current_organization)
      vol = create(:volunteer, casa_org: current_organization)
      sup = create(:supervisor, casa_org: current_organization)

      visit "/"

      expect(page).to have_text "All CASA Admin"
      expect(page).to have_text current_organization.name

      click_on current_organization.name

      expect(page).to have_text "Administrators"
      expect(page).to have_text "New CASA Admin"
      expect(page).to have_text "Back"
      expect(page).to_not have_text vol.email
      expect(page).to_not have_text sup.email
      expect(page).to have_text ca1.email
      expect(page).to have_text ca2.email
    end

    it "lets admin create a casa org" do
      visit "/"
      expect(page).to have_text "All CASA Admin"

      click_on "New CASA Organization"
      expect(page).to have_text "Create a new CASA Organization"

      fill_in "Name", with: "A new org"
      fill_in "Display name", with: "A new org"
      fill_in "Address", with: "123 Whole St"

      expect {
        click_on "Create CASA Organization"
        expect(page).to have_text "CASA Organization was successfully created."
      }.to change(
        CasaOrg,
        :count
      ).by(1)

      new_org = CasaOrg.last
      expect(new_org.name).to eq "A new org"
      expect(new_org.display_name).to eq "A new org"
      expect(new_org.address).to eq "123 Whole St"
    end

    it "requires name" do
      visit "/"
      expect(page).to have_text "All CASA Admin"

      click_on "New CASA Organization"
      expect(page).to have_text "Create a new CASA Organization"

      expect {
        click_on "Create CASA Organization"
        expect(page).to have_text "Name can't be blank"
      }.to change(
        CasaOrg,
        :count
      ).by(0)
    end

    it "allows an admin to create new casa_admins" do
      casa_org = create(:casa_org)
      create(:all_casa_admin)

      visit all_casa_admins_casa_org_path(casa_org)
      click_on "New CASA Admin"

      fill_in "Email", with: "admin1@example.com"
      fill_in "Display name", with: "Example Admin"
      click_on "Submit"

      expect(page).to have_text("CASA Admin was successfully created.")
    end
  end

  context "as any other user" do
    let(:current_organization) { create(:casa_org) }
    let(:casa_admin) { create(:casa_admin, casa_org: current_organization) }

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
