require "rails_helper"

RSpec.describe "all_casa_admins/casa_orgs/casa_admins/new", type: :system do
  let(:all_casa_admin) { create(:all_casa_admin, email: "theexample@example.com") }
  let(:organization) { create(:casa_org) }

  before do
    sign_in all_casa_admin
    visit new_all_casa_admins_casa_org_casa_admin_path(casa_org_id: organization.id)
  end

  it "allows an admin to create new casa_admins" do
    fill_in "Email", with: "admin1@example.com"
    fill_in "Display name", with: "Example Admin"
    click_on "Submit"

    expect(page).to have_text("CASA Admin was successfully created.")
  end
end
