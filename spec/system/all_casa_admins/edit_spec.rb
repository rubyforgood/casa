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
  end

  describe "with invalid parameters" do
    let!(:other_admin) { create(:all_casa_admin) }

    it "does not update email" do
      visit edit_all_casa_admins_path
      fill_in "all_casa_admin_email", with: other_admin.email
      click_on "Update Profile"
      expect(page).to have_text "already been taken"
    end
  end
end
