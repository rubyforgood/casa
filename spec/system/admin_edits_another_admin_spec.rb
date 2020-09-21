require "rails_helper"

RSpec.describe "admin editing admin users", type: :system do
  context "editing themselves" do
    it "can edit their password" do
      admin = create(:casa_admin)

      sign_in admin
      visit root_path
      expect(page).to have_selector("#admins")

      within "#admin-#{admin.id}" do
        click_on "Edit"
      end

      expect(page).to have_text("Edit Profile")
      expect(page).to have_text("Change Password")
    end
  end

  context "editing other admins" do
    it "can't change their password" do
      admin1 = create(:casa_admin)
      admin2 = create(:casa_admin)

      sign_in admin1

      visit root_path

      expect(page).to have_selector("#admins")

      within "#admin-#{admin2.id}" do
        click_on "Edit"
      end

      expect(page).to have_text("Edit Profile")
      expect(page).to_not have_text("Change Password")
    end
  end
end