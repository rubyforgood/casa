require "rails_helper"

RSpec.describe "all_casa_admin_edit_spec", type: :system do
  let(:admin) { create(:all_casa_admin) }

  before do
    sign_in admin
    visit edit_all_casa_admins_path
  end

  describe "with valid parameters" do
    it "updates email" do
      fill_in "all_casa_admin_email", with: "newemail@example.com"
      click_on "Update Profile"
      expect(page).to have_text "successfully updated"
    end

    it "updates password" do
      click_on "Change Password"
      fill_in "all_casa_admin_password", with: "newpassword"
      fill_in "all_casa_admin_password_confirmation", with: "newpassword"
      click_on "Update Password"
      expect(page).to have_text "successfully updated"
    end

    it "notifies password changed by email", :aggregate_failures do
      click_on "Change Password"

      fill_in "Password", with: "12345678"
      fill_in "Password Confirmation", with: "12345678"

      click_on "Update Password"

      page.has_content?("Password was successfully updated.")

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
      expect(ActionMailer::Base.deliveries.first.body.encoded)
        .to match("Your CASA password has been changed.")
    end
  end

  describe "with invalid parameters" do
    let!(:other_admin) { create(:all_casa_admin) }

    it "does not update email" do
      visit edit_all_casa_admins_path
      fill_in "all_casa_admin_email", with: other_admin.email
      click_on "Update Profile"
      expect(page).to have_text "already been taken"
    end

    it "does not update password" do
      click_on "Change Password"
      fill_in "all_casa_admin_password", with: "newpassword"
      fill_in "all_casa_admin_password_confirmation", with: "badmatch"
      click_on "Update Password"
      expect(page).to have_text "confirmation doesn't match"
    end
  end
end
