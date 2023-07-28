require 'rails_helper'

RSpec.describe 'Banners', type: :system, js: true do
  let(:admin) { create(:casa_admin) }
  let(:organization) { admin.casa_org }

  it 'add a banner' do
    sign_in admin

    visit banners_path
    click_on 'New Banner'
    fill_in 'Name', with: 'Volunteer Survey Announcement'
    check 'Active?'
    fill_in_rich_text_area 'banner_content', with: 'Please fill out this survey.'
    click_on 'Submit'

    visit banners_path
    expect(page).to have_text('Volunteer Survey Announcement')

    visit banners_path
    within '#banners' do
      click_on 'Edit', match: :first
    end
    fill_in 'Name', with: 'Better Volunteer Survey Announcement'
    click_on 'Submit'

    visit banners_path
    expect(page).to have_text('Better Volunteer Survey Announcement')

    visit root_path
    expect(page).to have_text('Please fill out this survey.')
  end
end
