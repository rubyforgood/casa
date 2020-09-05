require "rails_helper"

describe "AllCasaAdmin auth", type: :system do
  context "when authenticated user" do
    let(:all_casa_admin) { create(:all_casa_admin) }
    before { sign_in all_casa_admin }

    it "renders AllCasaAdmin dashboard page" do
      visit "/"
      expect(page).to have_text "Welcome Super Admin!"
    end

    it "allows sign out" do
      visit "/"
      click_link "Log out"
      expect(page).to_not have_text "sign in before continuing"
      expect(page).to have_text "Signed out successfully"
    end
  end
end
