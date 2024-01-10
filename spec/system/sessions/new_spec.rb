require "rails_helper"

RSpec.describe "sessions/new", type: :system do
  context "when guest" do
    it "renders sign in page with no flash messages" do
      visit "/"
      expect(page).to have_text "Login"
      expect(page).to_not have_text "sign in before continuing"
    end

    %w[volunteer supervisor casa_admin].each do |user_type|
      before do
        visit "/"
      end

      it "allows #{user_type} to click email link" do
        expect(page).to have_text "Want to use the CASA Volunteer Tracking App?"
        expect(page).to have_link("casa@rubyforgood.org", href: "mailto:casa@rubyforgood.org?Subject=CASA%20Interest")
      end

      it "renders sign in page with no flash messages" do
        expect(page).to have_text "Login"
        expect(page).to_not have_text "sign in before continuing"
      end

      context "when a #{user_type} fills in their email and password" do
        let!(:user) { create(user_type.to_sym) }

        before do
          visit "/users/sign_in"
          fill_in "Email", with: user.email
          fill_in "Password", with: "12345678"
          within ".actions" do
            find("#log-in").click
          end
        end

        it "allows them to sign in" do
          expect(page).to have_text user.email
        end

        context "but they are inactive" do
          let!(:user) { create(user_type.to_sym, active: false) }

          it "does not allow them to sign in" do
            expect(page).to have_text I18n.t("devise.failure.inactive")
          end
        end
      end
    end

    it "does not allow AllCasaAdmin to sign in" do
      user = build_stubbed(:all_casa_admin)

      visit "/users/sign_in"
      expect(page).to have_text "Log In"
      expect(page).to_not have_text "sign in before continuing"

      fill_in "Email", with: user.email
      fill_in "Password", with: "12345678"
      within ".actions" do
        find("#log-in").click
      end

      expect(page).to have_text "Invalid Email or password"
    end
  end

  context "when authenticated admin" do
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
