require "rails_helper"

RSpec.describe "Authentication", type: :system do
  context "when guest" do
    it "renders sign in page with no flash messages" do
      visit "/"
      expect(page).to have_text "Log in"
      expect(page).to_not have_text "sign in before continuing"
    end
  end

  context "when authenticated user" do
    let(:user) { create(:casa_admin) }
    before { sign_in user }

    it "renders dashboard page and shows correct flash message upon sign out" do
      visit "/"
      expect(page).to have_text "Volunteers"
      click_link "Log out"
      expect(page).to_not have_text "sign in before continuing"
      expect(page).to have_text "Signed out successfully"
    end
  end
end
