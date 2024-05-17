require "rails_helper"

RSpec.describe "User Login", type: :system do
  %w[volunteer supervisor casa_admin].each do |user_type|
    let!(:user) { create(user_type.to_sym) }
    it "creates a login activity record on successful login" do
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: "12345678"
      within ".actions" do
        find("#log-in").click
      end

      expect(page).to have_text user.email

      login_activity = LoginActivity.last
      expect(login_activity.user).to eq(user)
      expect(login_activity.success).to be true
    end

    it "creates a login activity record on failed login" do
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: "wrong_password"
      within ".actions" do
        find("#log-in").click
      end

      expect(page).to have_content("Invalid Email or password.")

      login_activity = LoginActivity.last
      expect(login_activity.success).to be false
      expect(login_activity.failure_reason).to eq("invalid")
    end
  end
end
