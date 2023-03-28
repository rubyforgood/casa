require "rails_helper"

RSpec.describe "users/passwords/new", type: :system do
  before do
    visit new_user_session_path
    click_on "Forgot your password?"
  end

  it "displays error messages for non-existent user" do
    fill_in "Email", with: "tangerine@forward.com"
    fill_in "Phone number", with: "+16578900012"

    click_on "Send me reset password instructions"
    expect(page).to have_content "1 error prohibited this User from being saved:"
    expect(page).to have_text("User does not exist.")
  end

  it "displays phone number error messages for incorrect formatting" do
    create(:user, email: "glados@aperture.labs")
    fill_in "Email", with: "glados@aperture.labs"
    fill_in "Phone number", with: "2134567eee"

    click_on "Send me reset password instructions"
    expect(page).to have_content "1 error prohibited this User from being saved:"
    expect(page).to have_text("Phone number must be 12 digits including country code (+1)")
  end

  it "displays error if user tries to submit empty form" do
    click_on "Send me reset password instructions"
    expect(page).to have_text("Please enter at least one field.")
  end

  it "redirects to sign up page for email" do
    create(:user, email: "glados@aperture.labs")
    fill_in "Email", with: "glados@aperture.labs"

    click_on "Send me reset password instructions"
    expect(page).to have_content "You will receive an email or SMS with instructions on how to reset your password in a few minutes."
  end
end
