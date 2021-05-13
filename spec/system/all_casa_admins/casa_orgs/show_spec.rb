require "rails_helper"

RSpec.describe "all_casa_admins/casa_orgs/show", :disable_bullet, type: :system do
  let(:all_casa_admin) { create(:all_casa_admin, email: "theexample@example.com") }
  let(:organization) { create(:casa_org) }

  before do
    sign_in all_casa_admin
    visit all_casa_admins_casa_org_path(organization)
  end

  it "has link for New CASA Admin" do
    click_on "New CASA Admin"

    expect(page).to have_field("Email")
  end
end
