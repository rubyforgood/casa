require "rails_helper"

RSpec.describe "users/passwords/new", type: :system do
  before do
    visit new_user_session_path
    click_on "Forgot your password?"
  end

  describe "reset password page" do
    it "displays error messages for non-existent user" do
      user = build(:user, email: "glados@example.com", phone_number: "+16578900012")

      fill_in "Email", with: "tangerine@example.com"
      fill_in "Phone number", with: user.phone_number

      click_on "Send me reset password instructions"
      expect(page).to have_content "If the account exists you will receive an email or SMS with instructions on how to reset your password in a few minutes."
    end

    it "displays phone number error messages for incorrect formatting" do
      user = create(:user, email: "glados@example.com", phone_number: "+16578900012")

      fill_in "Email", with: user.email
      fill_in "Phone number", with: "2134567eee"

      click_on "Send me reset password instructions"
      expect(page).to have_content "1 error prohibited this User from being saved:"
      expect(page).to have_text("Phone number must be 10 digits or 12 digits including country code (+1)")
    end

    it "displays error if user tries to submit an empty form" do
      click_on "Send me reset password instructions"
      expect(page).to have_text("Please enter at least one field.")
    end

    it "redirects to sign up page for email" do
      user = build(:user, email: "glados@example.com", phone_number: "+16578900012")

      fill_in "Email", with: user.email

      click_on "Send me reset password instructions"
      expect(page).to have_content "If the account exists you will receive an email or SMS with instructions on how to reset your password in a few minutes."
    end
  end

  describe "reset password email" do
    let!(:user) { create(:user, type: "Volunteer", email: "glados@aperture.labs") }

    it "sends user email" do
      fill_in "Email", with: user.email

      click_on "Send me reset password instructions"

      expect(page).to have_content "If the account exists you will receive an email or SMS with instructions on how to reset your password in a few minutes."

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.last.to).to eq([user.email])
    end

    it "has reset password url with token" do
      fill_in "Email", with: user.email
      click_on "Send me reset password instructions"

      expect(page).to have_content "If the account exists you will receive an email or SMS with instructions on how to reset your password in a few minutes."
      expect(reset_password_link(user.email)).to match(/http:\/\/localhost:3000\/users\/password\/edit\?reset_password_token=.*/)
    end

    it "url token matches user's encrypted token" do
      fill_in "Email", with: user.email
      click_on "Send me reset password instructions"

      expect(page).to have_content "If the account exists you will receive an email or SMS with instructions on how to reset your password in a few minutes."

      token = reset_password_link(user.email).gsub("http://localhost:3000/users/password/edit?reset_password_token=", "")
      encrypted_token = Devise.token_generator.digest(User, :reset_password_token, token)
      expect(User.find_by(reset_password_token: encrypted_token)).to be_present
    end

    it "user can update password" do
      fill_in "Email", with: user.email
      click_on "Send me reset password instructions"

      visit reset_password_link(user.email)
      fill_in "New password", with: "new password"
      fill_in "Confirm new password", with: "new password"
      click_on "Change my password"

      expect(page).to have_text("Your password has been changed successfully.")
      fill_in "Email", with: user.email
      fill_in "Password", with: "new password"
      click_on "Log In"

      expect(page).to have_text(user.display_name)
      expect(page).to have_text("My Cases")
      expect(page).not_to have_text("Sign in")
    end
  end
end

def reset_password_link(email_address)
  email = open_email(email_address)
  links = links_in_email(email)
  links[2]
end
