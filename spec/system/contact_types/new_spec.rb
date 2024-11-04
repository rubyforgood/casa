require "rails_helper"

RSpec.describe "contact_types/new" do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org:) }
  let(:contact_type_group) { create(:contact_type_group, casa_org:, name: "Contact type group 1") }
  let(:contact_type) { create(:contact_type, name: "Contact type 1", contact_type_group:) }

  before do
    sign_in admin

    visit new_contact_type_path(contact_type)
  end

  it "errors with invalid name" do
    fill_in "Name", with: ""
    click_on "Submit"

    expect(page).to have_text("Name can't be blank")
  end

  it "creates with valid data" do
    fill_in "Name", with: "New Contact Type test"
    click_on "Submit"

    expect(page).to have_text("Contact Type was successfully created.")
  end
end
