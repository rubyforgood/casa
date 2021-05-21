require "rails_helper"

RSpec.describe "dashboard/show", :disable_bullet, type: :system do
  let(:volunteer) { create(:volunteer, display_name: "Bob Loblaw") }
  context "volunteer user" do
    before do
      sign_in volunteer
    end

    it "sees all their casa cases" do
      casa_case_1 = create(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-1")
      casa_case_2 = create(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-2")
      casa_case_3 = create(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-3")
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case_1)
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case_2)

      visit root_path
      expect(page).to have_text("My Cases")
      expect(page).to have_text(casa_case_1.case_number)
      expect(page).to have_text(casa_case_2.case_number)
      expect(page).not_to have_text(casa_case_3.case_number)
    end

    it "sees volunteer names in Cases table as plain text" do
      casa_case = create(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-1")
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

      visit root_path

      expect(page).to have_text("Bob Loblaw")
      expect(page).to have_no_link("Bob Loblaw")
    end

    it "displays 'No active cases' when they don't have any assignments", js: true do
      visit root_path
      expect(page).to have_text("My Cases")
      expect(page).not_to have_text("Bob Loblaw")
    end
  end
end
