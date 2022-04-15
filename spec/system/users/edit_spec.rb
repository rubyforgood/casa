require "rails_helper"

RSpec.describe "users/edit", type: :system do
  let(:organization) { create(:casa_org) }
  let(:volunteer) do
    create(
      :volunteer,
      last_sign_in_at: "2020-01-01 00:00:00",
      current_sign_in_at: "2020-01-02 00:00:00"
    )
  end
  let(:admin) { create(:casa_admin) }
  let(:supervisor) { create(:supervisor) }

  context "volunteer user" do
    before do
      sign_in volunteer
      visit edit_users_path
    end

    it "displays password errors messages when user is unable to set a password with incorrect current password" do
      click_on "Change Password"

      fill_in "Current Password", with: "12345"
      fill_in "New Password", with: "123456789"
      fill_in "New Password Confirmation", with: "123456789"

      click_on "Update Password"
      expect(page).to have_content "1 error prohibited this password change from being saved:"
      expect(page).to have_text("Current password is incorrect")
    end

    it "displays password errors messages when user is unable to set a password" do
      click_on "Change Password"

      fill_in "Current Password", with: "12345678"
      fill_in "New Password", with: "123"
      fill_in "New Password Confirmation", with: "1234"

      click_on "Update Password"
      expect(page).to have_content "2 errors prohibited this password change from being saved:"
      expect(page).to have_text("Password confirmation doesn't match Password")
      expect(page).to have_text("Password is too short (minimum is #{User.password_length.min} characters)")
    end

    it "notifies a user when they update their password" do
      click_on "Change Password"

      fill_in "Current Password", with: "12345678"
      fill_in "New Password", with: "123456789"
      fill_in "New Password Confirmation", with: "123456789"

      click_on "Update Password"

      expect(page).to have_text("Password was successfully updated.")
    end

    it "notifies password changed by email", :aggregate_failures do
      click_on "Change Password"

      fill_in "Current Password", with: "12345678"
      fill_in "New Password", with: "123456789"
      fill_in "Password Confirmation", with: "123456789"

      click_on "Update Password"

      page.has_content?("Password was successfully updated.")

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
      expect(ActionMailer::Base.deliveries.first.body.encoded)
        .to match("Your CASA password has been changed.")
    end

    it "is not able to update the email if user is a volunteer" do
      expect(page).to have_field("Email", disabled: true)
    end

    it "displays current sign in date" do
      formatted_current_sign_in_at = I18n.l(volunteer.current_sign_in_at, format: :full, default: nil)
      formatted_last_sign_in_at = I18n.l(volunteer.last_sign_in_at, format: :full, default: nil)
      expect(page).to have_text("Last logged in #{formatted_current_sign_in_at}")
      expect(page).not_to have_text("Last logged in #{formatted_last_sign_in_at}")
    end

    it "displays Volunteer error message if no communication preference is selected" do
      uncheck "user_receive_email_notifications"
      click_on "Save Preferences"
      expect(page).to have_content "1 error prohibited this Volunteer from being saved:"
      expect(page).to have_text("At least one communication preference must be selected.")
    end
  end

  context "supervisor user" do
    before do
      sign_in supervisor
      visit edit_users_path
    end

    it "notifies password changed by email", :aggregate_failures do
      click_on "Change Password"

      fill_in "Current Password", with: "12345678"
      fill_in "New Password", with: "123456789"
      fill_in "Password Confirmation", with: "123456789"

      click_on "Update Password"

      page.has_content?("Password was successfully updated.")

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
      expect(ActionMailer::Base.deliveries.first.body.encoded)
        .to match("Your CASA password has been changed.")
    end

    it "is not able to update the email if user is a supervisor" do
      expect(page).to have_field("Email", disabled: true)
    end

    it "displays Supervisor error message if no communication preference is selected" do
      uncheck "user_receive_email_notifications"
      click_on "Save Preferences"
      expect(page).to have_content "1 error prohibited this Supervisor from being saved:"
      expect(page).to have_text("At least one communication preference must be selected.")
    end
  end

  context "when admin" do
    let(:role) { "user" }
    before do
      sign_in admin
      visit edit_users_path
    end

    it "is not able to update the profile without display name as an admin" do
      fill_in "Display name", with: ""
      click_on "Update Profile"
      expect(page).to have_text("Display name can't be blank")
    end

    it_should_behave_like "shows error for invalid phone numbers"

    it "is able to update the email if user is a admin" do
      expect(page).to have_field("Email", disabled: false)
      fill_in "Email", with: "new_admin@example.com"
      click_on "Update Profile"
      expect(page).to have_text("Profile was successfully updated.")
      expect(page).to have_text("new_admin@example.com")
      assert_equal "new_admin@example.com", admin.reload.email
    end

    it "displays password errors messages when admin is unable to set a password" do
      click_on "Change Password"

      fill_in "Current Password", with: "12345678"
      fill_in "New Password", with: "123"
      fill_in "Password Confirmation", with: "1234"

      click_on "Update Password"
      expect(page).to have_content "2 errors prohibited this password change from being saved:"
      expect(page).to have_text("Password confirmation doesn't match Password")
      expect(page).to have_text("Password is too short (minimum is #{User.password_length.min} characters)")
    end

    it "display success message when admin update password" do
      click_on "Change Password"

      fill_in "Current Password", with: "12345678"
      fill_in "New Password", with: "123456789"
      fill_in "Password Confirmation", with: "123456789"

      click_on "Update Password"

      expect(page).to have_text("Password was successfully updated.")
    end

    it "notifies password changed by email", :aggregate_failures do
      click_on "Change Password"

      fill_in "Current Password", with: "12345678"
      fill_in "New Password", with: "123456789"
      fill_in "Password Confirmation", with: "123456789"

      click_on "Update Password"

      page.has_content?("Password was successfully updated.")

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
      expect(ActionMailer::Base.deliveries.first.body.encoded)
        .to match("Your CASA password has been changed.")
    end

    it "displays Casa admin error message if no communication preference is selected" do
      uncheck "user_receive_email_notifications"
      click_on "Save Preferences"
      expect(page).to have_content "1 error prohibited this Casa admin from being saved:"
      expect(page).to have_text("At least one communication preference must be selected.")
    end
  end
end
