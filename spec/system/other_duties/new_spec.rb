require "rails_helper"

RSpec.describe "other_duties/new" do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org:) }
  let(:case_number) { "12345" }
  let(:next_year) { (Time.zone.now.year + 1).to_s }
  let(:court_date) { 21.days.from_now }

  let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org:) }

  before do
    sign_in volunteer
    visit root_path
  end

  context "as a volunteer", :js do
    it "sees a New Duty link" do
      visit other_duties_path
      expect(page).to have_link("New Duty", href: new_other_duty_path)
    end

    it "sees all their other duties", :js do
      volunteer_2 = create(:volunteer, display_name: "Other Volunteer")

      other_duty_1 = create(:other_duty, notes: "Test 1", creator_id: volunteer.id)
      other_duty_2 = create(:other_duty, notes: "Test 2", creator_id: volunteer.id)
      other_duty_3 = create(:other_duty, notes: "Test 3", creator_id: volunteer_2.id)

      visit other_duties_path

      expect(page).to have_text("Other Duties")
      expect(page).to have_text(other_duty_1.notes)
      expect(page).to have_text(other_duty_2.notes)
      expect(page).to have_no_text(other_duty_3.notes)
    end

    it "has an error if a new duty is attempted to be created without any notes" do
      click_on "Other Duties"
      click_on "New Duty"

      click_on "Submit"

      message = page.find_by_id("other_duty_notes").native.attribute("validationMessage")
      expect(message).to match(/Please fill (in|out) this field./)
    end
  end
end
