require "rails_helper"

RSpec.describe "casa_cases/new", type: :system do
  let(:casa_org) { build(:casa_org) }
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
        fourteen_years = (Date.today.year - 14).to_s
        fill_in "Case number", with: case_number

        select "1", from: "casa_case_court_report_due_date_3i"
        select "April", from: "casa_case_court_report_due_date_2i"
        select next_year, from: "casa_case_court_report_due_date_1i"

        select "December", from: "casa_case_birth_month_year_youth_2i"
        select fourteen_years, from: "casa_case_birth_month_year_youth_1i"

        check "Transition aged youth"
        has_checked_field? "Transition aged youth"

        select "Submitted", from: "casa_case_court_report_status"

        within ".top-page-actions" do
          click_on "Create CASA Case"
        end

        new_casa_case = CasaCase.find_by(case_number: case_number)
        expect(new_casa_case.has_transitioned?).to be_truthy
        expect(new_casa_case.birth_month_year_youth).to eq(Date.new(2006, 12, 1))

        expect(page.body).to have_content(case_number)
        expect(page).to have_content("CASA case was successfully created.")
        expect(page).to have_content("Court Report Due Date: Thursday, 1-APR-2021") # accurate for frozen time
        expect(page).to have_content("Transition Aged Youth: Yes")
      end
    end
  end

  context "when non-mandatory fields are not filled" do
    it "is successful" do
      fill_in "Case number", with: case_number

      five_years = (Date.today.year - 5).to_s
      select "March", from: "casa_case_birth_month_year_youth_2i"
      select five_years, from: "casa_case_birth_month_year_youth_1i"

      within ".actions" do
        click_on "Create CASA Case"
      end

      expect(page.body).to have_content(case_number)
      expect(page).to have_content("CASA case was successfully created.")
      expect(page).to have_content("Next Court Date:")
      expect(page).to have_content("Court Report Due Date:")
      expect(page).to have_content("Transition Aged Youth: No")
    end
  end

  context "when the case number field is not filled" do
    it "does not create a new case" do
      within ".actions" do
        click_on "Create CASA Case"
      end

      expect(page).to have_current_path(casa_cases_path, ignore_query: true)
      expect(page).to have_content("Case number can't be blank")
    end
  end

  context "when the case number already exists in the organization" do
    let!(:casa_case) { create(:casa_case, case_number: case_number, casa_org: casa_org) }

    it "does not create a new case" do
      fill_in "Case number", with: case_number
      within ".actions" do
        click_on "Create CASA Case"
      end

      expect(page).to have_current_path(casa_cases_path, ignore_query: true)
      expect(page).to have_content("Case number has already been taken")
    end
  end

  context "contact types" do
    let(:contact_type_group) { create(:contact_type_group, casa_org: casa_org) }
    let!(:contact_type) { create(:contact_type, contact_type_group: contact_type_group) }

    it "are shown in groups" do
      visit new_casa_case_path

      expect(page).to have_content(contact_type.name)
      expect(page).to have_content(contact_type_group.name)
    end
  end
end
