require "rails_helper"

RSpec.describe "all casa admins with casa orgs", type: :system do
  let(:all_casa_admin) { create(:all_casa_admin) }
  let!(:casa_org) { create(:casa_org) }

  before { sign_in all_casa_admin }

  it "lets admin navigate to an organization and see casa_admins" do
    ca1 = create(:casa_admin, casa_org: casa_org)
    ca2 = create(:casa_admin, casa_org: casa_org)
    vol = create(:volunteer, casa_org: casa_org)
    sup = create(:supervisor, casa_org: casa_org)

    visit "/"

    expect(page).to have_text "All CASA Admin"
    expect(page).to have_text casa_org.name

    click_on casa_org.name

    expect(page).to have_text "Administrators"
    expect(page).to have_text "Back to dashboard"
    expect(page).to_not have_text vol.email
    expect(page).to_not have_text sup.email
    expect(page).to have_text ca1.email
    expect(page).to have_text ca2.email
  end
end
