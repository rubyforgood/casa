# frozen_string_literal: true

require "rails_helper"

RSpec.describe "AllCasaAdmin password change", type: :system do
  let(:admin) { create(:all_casa_admin, email: "all_casa_admin1@example.com", password: "12345678") }

  before do
    sign_in admin
    visit edit_all_casa_admins_path
    click_button "Change Password"
  end

  it "shows error when password fields are blank", :aggregate_failures, :js do
    click_button "Update Password"
    expect(page).to have_selector("#error_explanation.alert")
    expect(page).to have_text("Password can't be blank")
  end

  it "shows error when password confirmation doesn't match", :aggregate_failures, :js do
    fill_in "all_casa_admin[password]", with: "newpassword"
    fill_in "all_casa_admin[password_confirmation]", with: "wrongconfirmation"
    click_button "Update Password"
    expect(page).to have_selector("#error_explanation.alert")
    expect(page).to have_text("Password confirmation doesn't match Password")
  end

  it "shows success flash when password is updated", :aggregate_failures, :js do
    fill_in "all_casa_admin[password]", with: "newpassword"
    fill_in "all_casa_admin[password_confirmation]", with: "newpassword"
    click_button "Update Password"
    expect(page).to have_selector(".header-flash")
    expect(page).to have_text("Password was successfully updated.")
  end
end
