require "rails_helper"

RSpec.describe "users/edit", :disable_bullet, type: :system do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer) }
  let(:admin) { create(:casa_admin, casa_org_id: organization.id) }
  let(:supervisor) { create(:supervisor) }

  context "volunteer user" do
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

    it "is not able to update the email if user is a volunteer" do
      expect(page).to have_field("Email", disabled: true)
    end
  end

  context "supervisor user" do
    before do
      sign_in supervisor
      visit edit_users_path
    end

    it "is not able to update the email if user is a supervisor" do
      expect(page).to have_field("Email", disabled: true)
    end
  end

  context "when admin" do
    before do
      sign_in admin
      visit edit_users_path
    end

    it "is not able to update the profile without display name as an admin" do
      fill_in "Display name", with: ""
      click_on "Update Profile"
      expect(page).to have_text("Display name can't be blank")
    end

    it "is able to update the email if user is a admin" do
      expect(page).to have_field("Email", disabled: false)
      fill_in "Email", with: "new_admin@example.com"
      click_on "Update Profile"
      expect(page).to have_text("Profile was successfully updated.")
      expect(page).to have_text("new_admin@example.com")
      assert_equal "new_admin@example.com", admin.reload.email
    end
  end
end
