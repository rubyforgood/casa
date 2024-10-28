require "rails_helper"

RSpec.describe "hearing_types/new" do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org:) }
  let(:hearing_type) { build_stubbed(:hearing_type, casa_org:, name: "Spec Test Hearing Type") }

  before do
    sign_in admin

    visit new_hearing_type_path
  end

  it "errors with invalid name" do
    fill_in "Name", with: ""
    click_on "Submit"

    expect(page).to have_text("Name can't be blank")
  end

  it "creates with valid data" do
    fill_in "Name", with: "Emergency Hearing Type"
    click_on "Submit"

    expect(page).to have_text("Hearing Type was successfully created.")
  end
end
