# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin: New Supervisors", type: :system do
  let(:admin) { create(:casa_admin) }

  it "allows admin to create a new supervisors" do
    sign_in admin
    visit new_supervisor_path

    fill_in "Email", with: "new_supervisor_email@example.com"
    fill_in "Display Name", with: "New Supervisor Display Name"

    expect {
      click_on "Create Supervisor"
    }.to change(User, :count).by(1)
  end
end
