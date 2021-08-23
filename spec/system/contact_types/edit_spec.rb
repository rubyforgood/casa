require "rails_helper"

RSpec.describe "contact_types/edit", type: :system do
  let!(:organization) { create(:casa_org) }
  let!(:admin) { create(:casa_admin, casa_org_id: organization.id) }
  let!(:contact_type_group) { create(:contact_type_group, casa_org: organization, name: "Contact type group 1") }
  let!(:contact_type) { create(:contact_type, name: "Contact type 1") }

  before do
    sign_in admin

    visit edit_contact_type_path(contact_type)
  end

  it "errors with invalid name" do
    fill_in "Name", with: ""
    click_on "Submit"

    expect(page).to have_text("Name can't be blank")
  end

  it "creates with valid data" do
    fill_in "Name", with: "Edit Contact Type test"
    click_on "Submit"

    expect(page).to have_text("Contact Type was successfully updated.")
  end
end
