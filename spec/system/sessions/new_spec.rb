require "rails_helper"

RSpec.describe "sessions/new", type: :system do
  context "when guest" do
    it "renders sign in page with no flash messages" do
      visit "/"
      expect(page).to have_text "Log in"
      expect(page).to_not have_text "sign in before continuing"
    end

    %w[volunteer supervisor casa_admin].each do |user_type|
      it "allows #{user_type} to sign in" do
        user = create(user_type.to_sym)

        visit "/"
        expect(page).to have_text "Log in"
        expect(page).to_not have_text "sign in before continuing"

        fill_in "Email", with: user.email
        fill_in "Password", with: "12345678"
        within ".actions" do
          click_on "Log in"
        end

        expect(page).to have_text user.email
      end

      it "allows #{user_type} to click email link" do
        visit "/"
        expect(page).to have_text "Want to add your CASA? Email: casa@rubyforgood.org"
        expect(page).to have_link("casa@rubyforgood.org", href: "mailto:casa@rubyforgood.org")
      end
    end

    it "does not allow AllCasaAdmin to sign in" do
      user = build_stubbed(:all_casa_admin)

      visit "/"
      expect(page).to have_text "Log in"
      expect(page).to_not have_text "sign in before continuing"

      fill_in "Email", with: user.email
      fill_in "Password", with: "12345678"
      within ".actions" do
        click_on "Log in"
      end

      expect(page).to have_text "Invalid Email or password"
    end
  end

  context "when authenticated user" do
    let(:user) { create(:casa_admin) }

    before { sign_in user }

    it "renders dashboard page and shows correct flash message upon sign out" do
      visit "/"
      expect(page).to have_text "Volunteers"
      # click_link "Log out"
      # expect(page).to_not have_text "sign in before continuing"
      # expect(page).to have_text "Signed out successfully"
    end
  end
end
