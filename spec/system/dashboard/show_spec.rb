require "rails_helper"

RSpec.describe "dashboard/show", type: :system do
  let(:volunteer) { create(:volunteer, display_name: "Bob Loblaw") }
  let(:casa_admin) { create(:casa_admin, display_name: "John Doe") }

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
      expect(page).to have_no_text(casa_case_3.case_number)
    end

    it "volunteer does not see his name in Cases table" do
      casa_case = build(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-1")
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

      visit casa_cases_path

      expect(page).to have_no_css("td", text: "Bob Loblaw")
    end

    it "displays 'No active cases' when they don't have any assignments", :js do
      visit casa_cases_path
      expect(page).to have_text("My Cases")
      expect(page).to have_no_css("td", text: "Bob Loblaw")
      expect(page).to have_no_text("Detail View")
    end
  end

  context "admin user" do
    before do
      sign_in casa_admin
    end

    it "sees volunteer names in Cases table as a link" do
      casa_case = build(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-1")
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

      visit casa_cases_path

      expect(page).to have_text("Bob Loblaw")
      expect(page).to have_link("Bob Loblaw")
      expect(page).to have_css("td", text: "Bob Loblaw")
    end
  end
end
