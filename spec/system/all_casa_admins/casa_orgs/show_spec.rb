require "rails_helper"

RSpec.describe "all_casa_admins/casa_orgs/show", type: :system do
  it "has link for New CASA Admin" do
    all_casa_admin = build_stubbed(:all_casa_admin, email: "theexample@example.com")
    organization = create(:casa_org)
    sign_in all_casa_admin
    visit all_casa_admins_casa_org_path(organization)
    click_on "New CASA Admin"
    expect(page).to have_field("Email")
  end

  it "has link to return to all organizations", js: true do
    all_casa_admin = create(:all_casa_admin, email: "theexample@example.com")
    organization = create(:casa_org)
    sign_in all_casa_admin
    visit all_casa_admins_casa_org_path(organization)
    click_on "Return to Organizations"
    expect(page).to have_text("CASA Organizations")
  end
end
