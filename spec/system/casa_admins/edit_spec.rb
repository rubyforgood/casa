require "rails_helper"

RSpec.describe "casa_admins/edit", type: :system do
  let(:admin) { create :casa_admin }

  before { sign_in admin }

  context "with valid data" do
    it "can successfully edit user email and display name" do
      expected_email = "root@casa.com"
      expected_display_name = "Root Admin"

      visit edit_casa_admin_path(admin)

      fill_in "Email", with: expected_email
      fill_in "Display Name", with: expected_display_name

      click_on "Submit"

      admin.reload

      expect(page).to have_text "Admin was successfully updated."
      expect(admin.email).to eq expected_email
      expect(admin.display_name).to eq expected_display_name
    end
  end

  context "with invalid data" do
    it "shows error message for empty email" do
      visit edit_casa_admin_path(admin)

      fill_in "Email", with: ""
      fill_in "Display Name", with: ""

      click_on "Submit"

      expect(page).to have_text "Email can't be blank"
      expect(page).to have_text "Display name can't be blank"
    end
  end

  it "can successfully deactivate" do
    another = create(:casa_admin)
    visit edit_casa_admin_path(another)

    dismiss_confirm do
      click_on "Deactivate"
    end

    expect(page).not_to have_text("Admin was deactivated.")

    accept_confirm do
      click_on "Deactivate"
    end

    expect(page).to have_text("Admin was deactivated.")
    expect(another.reload.active).to be_falsey
  end
end
