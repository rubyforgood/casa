require "rails_helper"

RSpec.describe "Editing Profile", type: :system do
  let(:volunteer) { create(:volunteer) }

  before do
    sign_in volunteer
    visit edit_users_path
  end

  it "displays password errors messages when user is unable to set a password" do
    click_on "Change Password"

    fill_in "Password", with: "123"
    fill_in "Password Confirmation", with: "1234"

    click_on "Update Password"

    expect(page).to have_text("Password confirmation doesn't match Password")
    expect(page).to have_text("Password is too short (minimum is 6 characters)")
  end

  it "notifies a user when they update their password" do
    click_on "Change Password"

    fill_in "Password", with: "1234567"
    fill_in "Password Confirmation", with: "1234567"

    click_on "Update Password"

    expect(page).to have_text("Password was successfully updated.")
  end
end
