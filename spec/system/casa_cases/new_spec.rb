require "rails_helper"

RSpec.describe "casa_cases/new", type: :system do
  context "when signed in as a Casa Org Admin" do
    context "when all fields are filled" do
      let(:casa_org) { build(:casa_org) }
      let(:admin) { create(:casa_admin, casa_org: casa_org) }
      let(:contact_type_group) { create(:contact_type_group, casa_org: casa_org) }
      let!(:contact_type) { create(:contact_type, contact_type_group: contact_type_group) }
      let(:volunteer_display_name) { "Test User" }
      let!(:supervisor) { create(:supervisor, casa_org: casa_org) }
      let!(:volunteer) { create(:volunteer, display_name: volunteer_display_name, supervisor: supervisor, casa_org: casa_org) }

      it "is successful", js: true do
        case_number = "12345"

        sign_in admin
        visit root_path

        click_on "Cases"
        click_on "New Case"

        travel_to Time.zone.local(2020, 12, 1) do
          court_date = 21.days.from_now
          fourteen_years = (Date.today.year - 14).to_s
          fill_in "Case number", with: case_number

          fill_in "Court Date", with: court_date

          select "March", from: "casa_case_birth_month_year_youth_2i"
          select fourteen_years, from: "casa_case_birth_month_year_youth_1i"

          select "Submitted", from: "casa_case_court_report_status"

          find(".ts-control").click
          find("span", text: contact_type.name).click
          find(".ts-control").click

          select "Test User", from: "casa_case[case_assignments_attributes][0][volunteer_id]"

          within ".top-page-actions" do
            click_on "Create CASA Case"
          end

          expect(page).to have_content(case_number)
          expect(page).to have_content(I18n.l(court_date, format: :day_and_date))
          expect(page).to have_content("CASA case was successfully created.")
          expect(page).not_to have_content("Court Report Due Date: Thursday, 1-APR-2021") # accurate for frozen time
          expect(page).to have_content("Transition Aged Youth: Yes")
          expect(page).to have_content(volunteer_display_name)
        end
      end
    end

    context "when non-mandatory fields are not filled" do
      it "is successful", js: true do
        casa_org = build(:casa_org)
        admin = create(:casa_admin, casa_org: casa_org)
        contact_type_group = create(:contact_type_group, casa_org: casa_org)
        contact_type = create(:contact_type, contact_type_group: contact_type_group)
        case_number = "12345"

        sign_in admin
        visit new_casa_case_path

        fill_in "Case number", with: case_number
        fill_in "Next Court Date", with: DateTime.now.next_month
        five_years = (Date.today.year - 5).to_s
        select "March", from: "casa_case_birth_month_year_youth_2i"
        select five_years, from: "casa_case_birth_month_year_youth_1i"

        find(".ts-control").click
        find("span", text: contact_type.name).click

        within ".actions-cc" do
          click_on "Create CASA Case"
        end

        expect(page).to have_content(case_number)
        expect(page).to have_content("CASA case was successfully created.")
        expect(page).to have_content("Next Court Date: ")
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
        check "casa_case_empty_court_date"

        within ".actions-cc" do
          click_on "Create CASA Case"
        end

        expect(find("#casa_case_empty_court_date")).to be_checked
        expect(page).to have_current_path(casa_cases_path, ignore_query: true)
        expect(page).to have_content("Case number can't be blank")
      end
    end

    context "when the court date field is not filled" do
      context "when empty court date checkbox is checked" do
        it "creates a new case", js: true do
          casa_org = build(:casa_org)
          admin = create(:casa_admin, casa_org: casa_org)
          contact_type_group = create(:contact_type_group, casa_org: casa_org)
          contact_type = create(:contact_type, contact_type_group: contact_type_group)
          case_number = "12345"

          sign_in admin
          visit new_casa_case_path

          fill_in "Case number", with: case_number
          five_years = (Date.today.year - 5).to_s
          select "March", from: "casa_case_birth_month_year_youth_2i"
          select five_years, from: "casa_case_birth_month_year_youth_1i"
          check "casa_case_empty_court_date"

          find(".ts-control").click
          find("span", text: contact_type.name).click

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
        it "does not create a new case", js: true do
          casa_org = build(:casa_org)
          admin = create(:casa_admin, casa_org: casa_org)
          contact_type_group = create(:contact_type_group, casa_org: casa_org)
          contact_type = create(:contact_type, contact_type_group: contact_type_group)
          case_number = "12345"

          sign_in admin
          visit new_casa_case_path

          fill_in "Case number", with: case_number
          five_years = (Date.today.year - 5).to_s
          select "March", from: "casa_case_birth_month_year_youth_2i"
          select five_years, from: "casa_case_birth_month_year_youth_1i"

          find(".ts-control").click
          find("span", text: contact_type.name).click

          within ".actions-cc" do
            click_on "Create CASA Case"
          end

          selected_contact_type = find(".ts-control .item").text

          expect(selected_contact_type).to eq(contact_type.name)
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
