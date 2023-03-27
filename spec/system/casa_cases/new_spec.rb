require "rails_helper"

RSpec.describe "casa_cases/new", type: :system do
  let(:casa_org) { build(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  let(:supervisor) { create(:supervisor, casa_org: casa_org) }
  let(:case_number) { "12345" }
  let!(:next_year) { (Date.today.year + 1).to_s }
  let(:court_date) { 21.days.from_now }
  let(:contact_type_group) { create(:contact_type_group, casa_org: casa_org) }
  let!(:contact_type) { create(:contact_type, contact_type_group: contact_type_group) }

  context "when signed in as a Casa Org Admin" do
    before do
      sign_in admin
      visit root_path
      click_on "Cases"

      click_on "New Case"
    end

    context "when all fields are filled" do
      it "is successful", js: true do
        travel_to Time.zone.local(2020, 12, 1) do
          fourteen_years = (Date.today.year - 14).to_s
          fill_in "Case number", with: case_number

          fill_in "Court Date", with: court_date.strftime("%Y/%m/%d")

          select "March", from: "casa_case_birth_month_year_youth_2i"
          select fourteen_years, from: "casa_case_birth_month_year_youth_1i"

          select "Submitted", from: "casa_case_court_report_status"

          check contact_type.name

          within ".top-page-actions" do
            click_on "Create CASA Case"
          end

          expect(page.body).to have_content(case_number)
          expect(page).to have_content(I18n.l(court_date, format: :day_and_date))
          expect(page).to have_content("CASA case was successfully created.")
          expect(page).not_to have_content("Court Report Due Date: Thursday, 1-APR-2021") # accurate for frozen time
          expect(page).to have_content("Transition Aged Youth: Yes")
        end
      end
    end

    context "when non-mandatory fields are not filled" do
      it "is successful" do
        fill_in "Case number", with: case_number
        fill_in "Next Court Date", with: DateTime.now.next_month.strftime("%Y/%m/%d")
        five_years = (Date.today.year - 5).to_s
        select "March", from: "casa_case_birth_month_year_youth_2i"
        select five_years, from: "casa_case_birth_month_year_youth_1i"

        within ".actions-cc" do
          click_on "Create CASA Case"
        end

        expect(page.body).to have_content(case_number)
        expect(page).to have_content("CASA case was successfully created.")
        expect(page).to have_content("Next Court Date:")
        expect(page).not_to have_content("Court Report Due Date:")
        expect(page).to have_content("Transition Aged Youth: No")
      end
    end

    context "when the case number field is not filled" do
      it "does not create a new case" do
        within ".actions-cc" do
          click_on "Create CASA Case"
        end

        expect(page).to have_current_path(casa_cases_path, ignore_query: true)
        expect(page).to have_content("Case number can't be blank")
      end
    end

    context "when the court date field is not filled" do
      context "when empty court date checkbox is checked" do
        it "creates a new case" do
          fill_in "Case number", with: case_number
          five_years = (Date.today.year - 5).to_s
          select "March", from: "casa_case_birth_month_year_youth_2i"
          select five_years, from: "casa_case_birth_month_year_youth_1i"
          check "casa_case_empty_court_date"

          within ".actions-cc" do
            click_on "Create CASA Case"
          end

          expect(page.body).to have_content(case_number)
          expect(page).to have_content("CASA case was successfully created.")
          expect(page).to have_content("Next Court Date:")
          expect(page).not_to have_content("Court Report Due Date:")
          expect(page).to have_content("Transition Aged Youth: No")
        end
      end

      context "when empty court date checkbox is not checked" do
        it "does not create a new case" do
          fill_in "Case number", with: case_number
          five_years = (Date.today.year - 5).to_s
          select "March", from: "casa_case_birth_month_year_youth_2i"
          select five_years, from: "casa_case_birth_month_year_youth_1i"

          within ".actions-cc" do
            click_on "Create CASA Case"
          end

          expect(page).to have_current_path(casa_cases_path, ignore_query: true)
          expect(page).to have_content("Court dates date can't be blank")
        end
      end
    end

    context "when the case number already exists in the organization" do
      let!(:casa_case) { create(:casa_case, case_number: case_number, casa_org: casa_org) }

      it "does not create a new case" do
        fill_in "Case number", with: case_number
        within ".actions-cc" do
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

    context "when trying to assign a volunteer to a case" do
      it "should not be able to assign volunteers" do
        visit new_casa_case_path

        expect(page).not_to have_content("Manage Volunteers")
        expect(page).not_to have_css("#volunteer-assignment")
      end
    end
  end

  context "when signed in as a supervisor" do
    before do
      sign_in supervisor
      visit root_path
      click_on "Cases"
    end

    it "should not provide option to make new case" do
      expect(page).not_to have_button("New Case")
    end
  end
end