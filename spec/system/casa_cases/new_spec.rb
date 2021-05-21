require "rails_helper"

RSpec.describe "casa_cases/new", :disable_bullet, type: :system do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  let(:case_number) { "12345" }
  let!(:next_year) { (Date.today.year + 1).to_s }

  before do
    sign_in admin
    visit root_path
    click_on "Cases"

    click_on "New Case"
  end

  context "when all fields are filled" do
    it "is successful", js: true do
      travel_to Time.zone.local(2020, 12, 1) do
        next_year = (Date.today.year + 1).to_s
        fill_in "Case number", with: case_number
        select "3", from: "casa_case_court_date_3i"
        select "March", from: "casa_case_court_date_2i"
        select next_year, from: "casa_case_court_date_1i"

        select "1", from: "casa_case_court_report_due_date_3i"
        select "April", from: "casa_case_court_report_due_date_2i"
        select next_year, from: "casa_case_court_report_due_date_1i"

        check "Transition aged youth"
        has_checked_field? "Transition aged youth"

        select "Submitted", from: "casa_case_court_report_status"

        click_on "Create CASA Case"

        expect(page.body).to have_content(case_number)
        expect(page).to have_content("CASA case was successfully created.")
        expect(page).to have_content("Next Court Date: Wednesday, 3-MAR-2021") # accurate for frozen time
        expect(page).to have_content("Court Report Due Date: Thursday, 1-APR-2021") # accurate for frozen time
        expect(page).to have_content("Transition Aged Youth: Yes")
      end
    end
  end

  context "when non-mandatory fields are not filled" do
    it "is successful" do
      fill_in "Case number", with: case_number
      click_on "Create CASA Case"

      expect(page.body).to have_content(case_number)
      expect(page).to have_content("CASA case was successfully created.")
      expect(page).to have_content("Next Court Date:")
      expect(page).to have_content("Court Report Due Date:")
      expect(page).to have_content("Transition Aged Youth: No")
    end
  end

  context "when the case number field is not filled" do
    it "does not create a new case" do
      click_on "Create CASA Case"

      expect(page).to have_current_path(casa_cases_path, ignore_query: true)
      expect(page).to have_content("Case number can't be blank")
    end
  end

  context "when the case number already exists in the organization" do
    let!(:casa_case) { create(:casa_case, case_number: case_number, casa_org: casa_org) }

    it "does not create a new case" do
      fill_in "Case number", with: case_number
      click_on "Create CASA Case"

      expect(page).to have_current_path(casa_cases_path, ignore_query: true)
      expect(page).to have_content("Case number has already been taken")
    end
  end
end
