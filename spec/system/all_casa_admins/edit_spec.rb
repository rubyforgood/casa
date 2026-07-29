# frozen_string_literal: true

require "rails_helper"

RSpec.describe "AllCasaAdmin edit page", type: :system do
  let(:admin) { create(:all_casa_admin) }

  before do
    sign_in admin
    visit edit_all_casa_admins_path
  end

  it "shows the password section only after clicking 'Change password'", :aggregate_failures, :js do
    expect_password_section_hidden

    # Click the Change password button
    click_button "Change password"

    # Password section should now be visible
    expect_password_section_visible
  end

  private

  def expect_password_section_hidden
    expect(page).to have_selector("#collapseOne.hidden", visible: :all)
  end

  def expect_password_section_visible
    expect(page).to have_selector("#collapseOne:not(.hidden)")
    expect(page).to have_field("all_casa_admin[password]")
    expect(page).to have_field("all_casa_admin[password_confirmation]")
    expect(page).to have_button("Update password")
  end
end
