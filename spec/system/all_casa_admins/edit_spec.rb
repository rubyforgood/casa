# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AllCasaAdmin edit page', type: :system do
  let(:admin) { create(:all_casa_admin) }

  before do
    sign_in admin
    visit edit_all_casa_admins_path
  end

  it "shows the password section only after clicking 'Change Password'", :aggregate_failures, :js do
    expect_password_section_hidden

    # Click the Change Password button
    click_button 'Change Password'

    # Password section should now be visible
    expect_password_section_visible
  end

  private

  def expect_password_section_hidden
    expect(page).to have_selector('#collapseOne.collapse:not(.show)', visible: :all)
  end

  def expect_password_section_visible
    expect(page).to have_selector('#collapseOne.collapse.show')
    expect(page).to have_field('all_casa_admin[password]')
    expect(page).to have_field('all_casa_admin[password_confirmation]')
    expect(page).to have_button('Update Password')
  end
end
