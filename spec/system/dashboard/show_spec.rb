require "rails_helper"

RSpec.describe "dashboard/show", type: :system do
  let(:volunteer) { create(:volunteer, display_name: "Bob Loblaw") }
  context "volunteer user" do
    before do
      sign_in volunteer
    end

    it "sees all their casa cases" do
      casa_case_1 = build(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-1")
      casa_case_2 = build(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-2")
      casa_case_3 = build(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-3")
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case_1)
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case_2)

      visit casa_cases_path
      expect(page).to have_text("My Cases")
      expect(page).to have_text(casa_case_1.case_number)
      expect(page).to have_text(casa_case_2.case_number)
      expect(page).not_to have_text(casa_case_3.case_number)
    end

    it "sees volunteer names in Cases table as plain text" do
      casa_case = build(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-1")
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

      visit casa_cases_path

      expect(page).to have_text("Bob Loblaw")
      expect(page).to have_no_link("Bob Loblaw")
      expect(page).to have_css("td", text: "Bob Loblaw")
    end

    it "displays 'No active cases' when they don't have any assignments", js: true do
      visit casa_cases_path
      expect(page).to have_text("My Cases")
      expect(page).not_to have_css("td", text: "Bob Loblaw")
      expect(page).not_to have_text("Detail View")
    end

    it "sees all their other duties", js: true do
      volunteer_2 = create(:volunteer, display_name: "Other Volunteer")

      other_duty_1 = create(:other_duty, notes: "Test 1", creator_id: volunteer.id)
      other_duty_2 = create(:other_duty, notes: "Test 2", creator_id: volunteer.id)
      other_duty_3 = create(:other_duty, notes: "Test 3", creator_id: volunteer_2.id)

      visit casa_cases_path

      expect(page).to have_text("Other Duties")
      expect(page).to have_text(other_duty_1.notes)
      expect(page).to have_text(other_duty_2.notes)
      expect(page).to_not have_text(other_duty_3.notes)
    end

    it "has a New Duty link" do
      visit casa_cases_path
      expect(page).to have_link("New Duty", href: new_other_duty_path)
    end
  end
end
