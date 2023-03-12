require "rails_helper"

RSpec.describe "other_duties/new", type: :system do
  let(:casa_org) { build(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  let(:case_number) { "12345" }
  let!(:next_year) { (Date.today.year + 1).to_s }
  let(:court_date) { 21.days.from_now }

  let(:organization) { build(:casa_org) }
  let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org: organization) }

  before do
    sign_in volunteer
    visit root_path
  end

  context "as a volunteer", js: true do
    it "should have an error if a new duty is attempted to be created without any notes" do
      click_on "My Cases"
      click_on "New Duty"

      click_on "Submit"

      message = page.find("#other_duty_notes").native.attribute("validationMessage")
      expect(message).to match(/Please fill (in|out) this field./)
    end
  end
end
