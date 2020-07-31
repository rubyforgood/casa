# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin: New Supervisors', type: :system, js: true do
  let(:admin) { create(:user, :casa_admin) }

  it 'allows admin to creates a new supervisors' do
    volunteer = create(:user, :volunteer, display_name: "Assign Me")

    sign_in admin
    visit new_supervisor_path

    fill_in "Email", with: "new_supervisor_email@example.com"
    fill_in "Display Name", with: "New Supervisor Display Name"

    find(class: 'filter-option-inner-inner').click
    save_and_open_page
    save_and_open_screenshot
    find(class: 'text').click

    expect do
      click_on "Create Supervisor"
    end.to change(User, :count).by(1)

    expect(volunteer.reload.supervisor).to eq(User.last)
  end
end
