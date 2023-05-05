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
  SmsNotificationEvent.delete_all
  SmsNotificationEvent.new(name: "sms_event_test_volunteer", user_type: Volunteer).save
  SmsNotificationEvent.new(name: "sms_event_test_supervisor", user_type: Supervisor).save
  SmsNotificationEvent.new(name: "sms_event_test_casa_admin", user_type: CasaAdmin).save

  context "volunteer user" do
    before do
      sign_in volunteer
      visit edit_users_path
    end

    it "displays password errors messages when user is unable to set a password with incorrect current password" do
      click_on "Change Password"

      fill_in "current_password", with: "12345"
      fill_in "New Password", with: "123456789"
      fill_in "New Password Confirmation", with: "123456789"

      click_on "Update Password"
      expect(page).to have_content "1 error prohibited this password change from being saved:"
      expect(page).to have_text("Current password is incorrect")
    end

    it "displays password errors messages when user is unable to set a password" do
      click_on "Change Password"

      fill_in "current_password", with: "12345678"
      fill_in "New Password", with: "123"
      fill_in "New Password Confirmation", with: "1234"

      click_on "Update Password"
      expect(page).to have_content "2 errors prohibited this password change from being saved:"
      expect(page).to have_text("Password confirmation doesn't match Password")
      expect(page).to have_text("Password is too short (minimum is #{User.password_length.min} characters)")
    end

    it "displays sms notification events for the volunteer user" do
      expect(page).to have_content "sms_event_test_volunteer"
      expect(page).not_to have_content "sms_event_test_supervisor"
      expect(page).not_to have_content "sms_event_test_casa_admin"
    end

    it "notifies a user when they update their password" do
      click_on "Change Password"

      fill_in "current_password", with: "12345678"
      fill_in "New Password", with: "123456789"
      fill_in "New Password Confirmation", with: "123456789"

      click_on "Update Password"

      expect(page).to have_text("Password was successfully updated.")
    end

    it "notifies password changed by email", :aggregate_failures do
      click_on "Change Password"

      fill_in "current_password", with: "12345678"
      fill_in "New Password", with: "123456789"
      fill_in "Password Confirmation", with: "123456789"

      click_on "Update Password"

      page.has_content?("Password was successfully updated.")

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
      expect(ActionMailer::Base.deliveries.first.body.encoded)
        .to match("Your CASA password has been changed.")
    end

    it "is able to send a confrimation email when Volunteer updates their email" do
      click_on "Change Email"
      expect(page).to have_field("New Email", disabled: false)

      fill_in "current_password_email", with: "12345678"

      fill_in "New Email", with: "new_volunteer@example.com"
      click_on "Update Email"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
      expect(ActionMailer::Base.deliveries.first.body.encoded)
        .to have_text("You can confirm your account email through the link below:")
    end

    it "displays email errors messages when user is unable to set a email with incorrect current password" do
      click_on "Change Email"

      fill_in "current_password_email", with: "12345"
      fill_in "New Email", with: "new_volunteer@example.com"

      click_on "Update Email"
      expect(page).to have_content "1 error prohibited this Volunteer from being saved:"
      expect(page).to have_text("Current password is incorrect")
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

    it "displays Volunteer error message if SMS communication preference is selected without adding a valid phone number" do
      uncheck "user_receive_email_notifications"
      check "user_receive_sms_notifications"
      click_on "Save Preferences"
      expect(page).to have_content "1 error prohibited this Volunteer from being saved:"
      expect(page).to have_text("Must add a valid phone number to receive SMS notifications.")
    end

    it "displays notification events selection as enabled if sms notification preference is selected", js: true do
      check "user_receive_sms_notifications"
      expect(page).to have_field("toggle-sms-notification-event", type: "checkbox", disabled: false)
    end

    it "displays notification events selection as disabled if sms notification preference is not selected", js: true do
      uncheck "user_receive_sms_notifications"
      expect(page).to have_field("toggle-sms-notification-event", type: "checkbox", disabled: true)
    end
  end

  context "supervisor user" do
    before do
      sign_in supervisor
      visit edit_users_path
    end

    it "notifies password changed by email", :aggregate_failures do
      click_on "Change Password"

      fill_in "current_password", with: "12345678"
      fill_in "New Password", with: "123456789"
      fill_in "Password Confirmation", with: "123456789"

      click_on "Update Password"

      page.has_content?("Password was successfully updated.")

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
      expect(ActionMailer::Base.deliveries.first.body.encoded)
        .to match("Your CASA password has been changed.")
    end

    it "is able to send a confrimation email when supervisor is updating email" do
      click_on "Change Email"
      expect(page).to have_field("New Email", disabled: false)

      fill_in "current_password_email", with: "12345678"

      fill_in "New Email", with: "new_supervisor@example.com"
      click_on "Update Email"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
      expect(ActionMailer::Base.deliveries.first.body.encoded)
        .to match("You can confirm your account email through the link below:")
    end

    it "displays email errors messages when user is unable to set a email with incorrect current password" do
      click_on "Change Email"

      fill_in "current_password_email", with: "12345"
      fill_in "New Email", with: "new_supervisor@example"

      click_on "Update Email"
      expect(page).to have_content "1 error prohibited this Supervisor from being saved:"
      expect(page).to have_text("Current password is incorrect")
    end

    it "displays sms notification events for the supervisor user" do
      expect(page).not_to have_content "sms_event_test_volunteer"
      expect(page).to have_content "sms_event_test_supervisor"
      expect(page).not_to have_content "sms_event_test_casa_admin"
    end

    it "displays Supervisor error message if no communication preference is selected" do
      uncheck "user_receive_email_notifications"
      click_on "Save Preferences"
      expect(page).to have_content "1 error prohibited this Supervisor from being saved:"
      expect(page).to have_text("At least one communication preference must be selected.")
    end

    it "displays Supervisor error message if SMS communication preference is selected without adding a valid phone number" do
      uncheck "user_receive_email_notifications"
      check "user_receive_sms_notifications"
      click_on "Save Preferences"
      expect(page).to have_content "1 error prohibited this Supervisor from being saved:"
      expect(page).to have_text("Must add a valid phone number to receive SMS notifications.")
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

    it "is able to send a confrimation email when Casa Admin updates their email" do
      click_on "Change Email"
      expect(page).to have_field("New Email", disabled: false)

      fill_in "current_password_email", with: "12345678"

      fill_in "New Email", with: "new_admin@example.com"
      click_on "Update Email"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
      expect(ActionMailer::Base.deliveries.first.body.encoded)
        .to match("You can confirm your account email through the link below:")
    end

    it "displays email errors messages when user is unable to set a email with incorrect current password" do
      click_on "Change Email"

      fill_in "current_password_email", with: "12345"
      fill_in "New Email", with: "new_admin@example.com"

      click_on "Update Email"
      expect(page).to have_content "1 error prohibited this Casa admin from being saved:"
      expect(page).to have_text("Current password is incorrect")
    end

    it "displays password errors messages when admin is unable to set a password" do
      click_on "Change Password"

      fill_in "current_password", with: "12345678"
      fill_in "New Password", with: "123"
      fill_in "Password Confirmation", with: "1234"

      click_on "Update Password"
      expect(page).to have_content "2 errors prohibited this password change from being saved:"
      expect(page).to have_text("Password confirmation doesn't match Password")
      expect(page).to have_text("Password is too short (minimum is #{User.password_length.min} characters)")
    end

    it "display success message when admin update password" do
      click_on "Change Password"

      fill_in "current_password", with: "12345678"
      fill_in "New Password", with: "123456789"
      fill_in "Password Confirmation", with: "123456789"

      click_on "Update Password"

      expect(page).to have_text("Password was successfully updated.")
    end

    it "displays sms notification events for the casa admin user" do
      expect(page).not_to have_content "sms_event_test_volunteer"
      expect(page).not_to have_content "sms_event_test_supervisor"
      expect(page).to have_content "sms_event_test_casa_admin"
    end

    it "notifies password changed by email", :aggregate_failures do
      click_on "Change Password"

      fill_in "current_password", with: "12345678"
      fill_in "New Password", with: "123456789"
      fill_in "Password Confirmation", with: "123456789"

      click_on "Update Password"

      page.has_content?("Password was successfully updated.")

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
      expect(ActionMailer::Base.deliveries.first.body.encoded)
        .to match("Your CASA password has been changed.")
    end

    it "displays admin error message if no communication preference is selected" do
      uncheck "user_receive_email_notifications"
      click_on "Save Preferences"
      expect(page).to have_content "1 error prohibited this Casa admin from being saved:"
      expect(page).to have_text("At least one communication preference must be selected.")
    end

    it "displays admin error message if SMS communication preference is selected without adding a valid phone number" do
      uncheck "user_receive_email_notifications"
      check "user_receive_sms_notifications"
      click_on "Save Preferences"
      expect(page).to have_content "1 error prohibited this Casa admin from being saved:"
      expect(page).to have_text("Must add a valid phone number to receive SMS notifications.")
    end
  end
end
