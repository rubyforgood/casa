require "rails_helper"

RSpec.describe "casa_cases/new", type: :system do
  context "when signed in as a Casa Org Admin" do
    context "when all fields are filled" do
      it "is successful", js: true do
        casa_org = build(:casa_org)
        admin = create(:casa_admin, casa_org: casa_org)
        contact_type_group = create(:contact_type_group, casa_org: casa_org)
        contact_type = create(:contact_type, contact_type_group: contact_type_group)
        case_number = "12345"
        court_date = 21.days.from_now

        sign_in admin
        visit root_path

        click_on "Cases"
        click_on "New Case"

        travel_to Time.zone.local(2020, 12, 1) do
          fourteen_years = (Date.today.year - 14).to_s
          fill_in "Case number", with: case_number

          fill_in "Court Date", with: court_date.strftime("%Y/%m/%d")

          select "March", from: "casa_case_birth_month_year_youth_2i"
          select fourteen_years, from: "casa_case_birth_month_year_youth_1i"

          select "Submitted", from: "casa_case_court_report_status"

          expect(page).to have_content(contact_type_group.name)
          check contact_type.name

          within ".top-page-actions" do
            click_on "Create CASA Case"
          end

          expect(page).to have_content(case_number)
          expect(page).to have_content(I18n.l(court_date, format: :day_and_date))
          expect(page).to have_content("CASA case was successfully created.")
          expect(page).not_to have_content("Court Report Due Date: Thursday, 1-APR-2021") # accurate for frozen time
          expect(page).to have_content("Transition Aged Youth: Yes")
        end
      end
    end

    context "when non-mandatory fields are not filled" do
      it "is successful" do
        casa_org = build(:casa_org)
        admin = create(:casa_admin, casa_org: casa_org)
        contact_type_group = create(:contact_type_group, casa_org: casa_org)
        create(:contact_type, contact_type_group: contact_type_group)
        case_number = "12345"

        sign_in admin
        visit new_casa_case_path

        fill_in "Case number", with: case_number
        fill_in "Next Court Date", with: DateTime.now.next_month.strftime("%Y/%m/%d")
        five_years = (Date.today.year - 5).to_s
        select "March", from: "casa_case_birth_month_year_youth_2i"
        select five_years, from: "casa_case_birth_month_year_youth_1i"

        within ".actions-cc" do
          click_on "Create CASA Case"
        end

        expect(page).to have_content(case_number)
        expect(page).to have_content("CASA case was successfully created.")
        expect(page).to have_content("Next Court Date:")
        expect(page).not_to have_content("Court Report Due Date:")
        expect(page).to have_content("Transition Aged Youth: No")
      end
    end

    context "when the case number field is not filled" do
      it "does not create a new case" do
        casa_org = build(:casa_org)
        admin = create(:casa_admin, casa_org: casa_org)

        sign_in admin
        visit new_casa_case_path

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
          casa_org = build(:casa_org)
          admin = create(:casa_admin, casa_org: casa_org)
          contact_type_group = create(:contact_type_group, casa_org: casa_org)
          create(:contact_type, contact_type_group: contact_type_group)
          case_number = "12345"

          sign_in admin
          visit new_casa_case_path

          fill_in "Case number", with: case_number
          five_years = (Date.today.year - 5).to_s
          select "March", from: "casa_case_birth_month_year_youth_2i"
          select five_years, from: "casa_case_birth_month_year_youth_1i"
          check "casa_case_empty_court_date"

          within ".actions-cc" do
            click_on "Create CASA Case"
          end

          expect(page).to have_content(case_number)
          expect(page).to have_content("CASA case was successfully created.")
          expect(page).to have_content("Next Court Date:")
          expect(page).not_to have_content("Court Report Due Date:")
          expect(page).to have_content("Transition Aged Youth: No")
        end
      end

      context "when empty court date checkbox is not checked" do
        it "does not create a new case" do
          casa_org = build(:casa_org)
          admin = create(:casa_admin, casa_org: casa_org)
          case_number = "12345"

          sign_in admin
          visit new_casa_case_path

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
      it "does not create a new case" do
        casa_org = build(:casa_org)
        admin = create(:casa_admin, casa_org: casa_org)
        case_number = "12345"
        _existing_casa_case = create(:casa_case, case_number: case_number, casa_org: casa_org)

        sign_in admin
        visit new_casa_case_path

        fill_in "Case number", with: case_number
        within ".actions-cc" do
          click_on "Create CASA Case"
        end

        expect(page).to have_current_path(casa_cases_path, ignore_query: true)
        expect(page).to have_content("Case number has already been taken")
      end
    end
  end
end
