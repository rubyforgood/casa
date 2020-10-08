require "rails_helper"

RSpec.describe "Edit Casa Org", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org_id: organization.id) }
  let(:hearing_type) { create(:hearing_type, casa_org: organization, name: "Spec Test Hearing Type") }

  before do
    sign_in admin

    visit edit_casa_org_path(organization)
  end

  it "loads casa org edit page" do
    expect(page).to have_text "Editing CASA Organization"
    expect(page).to_not have_text "sign in before continuing"
  end

  it "has hearing types content" do
    expect(page).to have_text("Spec Test Hearing Type")
    expect(page).to have_text("New Hearing Type")
  end
end
