require "rails_helper"

RSpec.describe "all_casa_admins/casa_orgs/new", type: :system do
  context "as an all casa admin" do
    let(:all_casa_admin) { create(:all_casa_admin, email: "theexample@example.com") }
    let(:organization) { build(:casa_org) }

    before do
      sign_in all_casa_admin
      visit new_all_casa_admins_casa_org_path
    end

    it "lets admin create a casa org" do
      create(:casa_org, name: "some name")
      expect(page).to have_text "Create a new CASA Organization"

      fill_in "Name", with: "some name"
      fill_in "Display name", with: "some name"
      fill_in "Address", with: "123 Whole St"

      expect {
        click_on "Create CASA Organization"
        expect(page).not_to have_text "CASA Organization was successfully created."
        expect(page).to have_text "1 error prohibited this Casa org from being saved:"
        expect(page).to have_text "Name has already been taken"
      }.to change(
        CasaOrg,
        :count
      ).by(0)

      fill_in "Name", with: "A new org"
      fill_in "Display name", with: "A new org"
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
      expect {
        click_on "Create CASA Organization"
        expect(page).to have_text "Name can't be blank"
      }.to change(
        CasaOrg,
        :count
      ).by(0)
    end
  end

  context "as any other user" do
    let(:organization) { build(:casa_org) }
    let(:casa_admin) { create(:casa_admin, casa_org: organization) }

    before { sign_in casa_admin }

    it "redirects to root" do
      visit new_all_casa_admins_casa_org_path
      expect(page).to have_text "All CASA Log In"
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
