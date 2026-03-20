require "rails_helper"

RSpec.describe "User Login", type: :system do
  %w[volunteer supervisor casa_admin].each do |user_type|
    let!(:user) { create(user_type.to_sym) }

    it "shows the user's email after successful login" do
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: "12345678"
      within ".actions" do
        find("#log-in").click
      end

      expect(page).to have_text user.email
    end

    it "shows an error message after failed login" do
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: "wrong_password"
      within ".actions" do
        find("#log-in").click
      end

      expect(page).to have_content(/invalid email or password/i)
    end
  end
end
