# frozen_string_literal: true

require "rails_helper"

RSpec.describe "contact_types/new", type: :system do
  let!(:organization) { create(:casa_org) }
  let!(:admin) { create(:casa_admin, casa_org: organization) }
  let!(:contact_type_group) { create(:contact_type_group, casa_org: organization, name: "Contact type group 1") }

  before do
    sign_in admin
    visit new_contact_type_path
  end

  context "with valid data" do
    it "creates contact type successfully" do
      fill_in "Name", with: "New Contact Type test"
      click_on "Submit"

      expect(page).to have_text("Contact Type was successfully created.")
    end
  end

  context "with invalid data" do
    it "shows error when name is blank" do
      fill_in "Name", with: ""
      click_on "Submit"

      expect(page).to have_text("Name can't be blank")
    end

    it "shows error when name is not unique within group" do
      create(:contact_type, name: "Existing Name", contact_type_group:)

      fill_in "Name", with: "Existing Name"
      select "Contact type group 1", from: "contact_type_contact_type_group_id"
      click_on "Submit"

      expect(page).to have_text("Name should be unique per contact type group")
    end
  end
end
