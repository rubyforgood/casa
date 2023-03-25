require "rails_helper"

RSpec.describe "all_casa_admins/sessions/new", type: :system do
  let(:all_casa_admin) { create(:all_casa_admin) }
  let(:volunteer) { build_stubbed(:volunteer) }

  context "when authenticated user" do
    before { sign_in all_casa_admin }

    it "renders AllCasaAdmin dashboard page" do
      visit "/"
      expect(page).to have_text "All CASA Admin"
    end

    it "allows sign out" do
      visit "/"
      find("#all-casa-log-out").click
      expect(page).to_not have_text "sign in before continuing"
      expect(page).to have_text "Signed out successfully"
      expect(page).to have_text "All CASA Log In"
    end
  end

  context "when unauthenticated" do
    it "shows sign in page" do
      visit "/all_casa_admins/sign_in"
      expect(page).to have_text "All CASA Log In"
    end

    it "allows sign in" do
      visit "/all_casa_admins/sign_in"

      fill_in "Email", with: all_casa_admin.email
      fill_in "Password", with: "12345678"
      within ".actions" do
        click_on "Log in"
      end

      expect(page).to have_text "All CASA Admin"
    end

    it "prevents User sign in" do
      visit "/all_casa_admins/sign_in"

      fill_in "Email", with: volunteer.email
      fill_in "Password", with: "12345678"
      within ".actions" do
        click_on "Log in"
      end

      expect(page).to have_text "Invalid Email or password"
    end
  end
end
