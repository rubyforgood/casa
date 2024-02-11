require "rails_helper"

RSpec.describe "view all volunteers", type: :system, js: true do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  context "admin user" do
    context "when no logo_url" do
      it "can see volunteers and navigate to their cases", js: true do
        volunteer = create(:volunteer, :with_assigned_supervisor, display_name: "User 1", email: "casa@example.com", casa_org: organization)
        volunteer.casa_cases << create(:casa_case, casa_org: organization, birth_month_year_youth: CasaCase::TRANSITION_AGE.years.ago)
        volunteer.casa_cases << create(:casa_case, casa_org: organization, birth_month_year_youth: CasaCase::TRANSITION_AGE.years.ago)
        casa_case = volunteer.casa_cases[0]

        sign_in admin

        visit volunteers_path

        expect(page).to have_text("User 1")
        expect(page).to have_text(casa_case.case_number)

        within "#volunteers" do
          click_on volunteer.casa_cases.first.case_number
        end

        expect(page).to have_text("CASA Case Details")
        expect(page).to have_text("Case number: #{casa_case.case_number}")
        expect(page).to have_text("Transition Aged Youth: Yes")
        expect(page).to have_text("Next Court Date:")
        expect(page).to have_text("Court Report Status: Not submitted")
        expect(page).to have_text("Assigned Volunteers:")
      end

      it "displays default logo" do
        sign_in admin

        visit volunteers_path

        expect(page.find("#casa-logo")["src"]).to match "default-logo"
        expect(page.find("#casa-logo")["alt"]).to have_content "CASA Logo"
      end
    end

    it "displays last attempted contact by default", js: true do
      travel_to Date.new(2021, 1, 1)
      create(:volunteer, :with_assigned_supervisor, display_name: "User 1", email: "casa@example.com", casa_org: organization)

      sign_in admin

      visit volunteers_path

      expect(page).to have_content(:visible, "Last Attempted Contact")
    end

    it "can show/hide columns on volunteers table", js: true do
      sign_in admin

      visit volunteers_path
      expect(page).to have_text("Pick displayed columns")

      click_on "Pick displayed columns"
      expect(page).to have_text("Name")
      expect(page).to have_text("Status")
      expect(page).to have_text("Contact Made In Past 60 Days")
      expect(page).to have_text("Last Attempted Contact")
      check "Name"
      check "Status"
      uncheck "Contact Made In Past 60 Days"
      uncheck "Last Attempted Contact"
      within(".modal-dialog") do
        click_button "Close"
      end

      expect(page).to have_text("Name")
      expect(page).to have_text("Status")
      within("#volunteers") do
        expect(page).to have_no_text("Contact Made In Past 60 Days")
        expect(page).to have_no_text("Last Attempted Contact")
      end
    end

    it "can filter volunteers", js: true do
      assigned_volunteers = create_list(:volunteer, 3, :with_assigned_supervisor, casa_org: organization)
      inactive_volunteers = create_list(:volunteer, 2, :inactive, casa_org: organization)
      unassigned_volunteers = create_list(:volunteer, 1, casa_org: organization)

      sign_in admin

      visit volunteers_path
      expect(page).to have_selector(".volunteer-filters")

      assigned_volunteers.each do |assigned_volunteer|
        expect(page).to have_text assigned_volunteer.display_name
      end
      unassigned_volunteers.each do |unassigned_volunteer|
        expect(page).to have_text unassigned_volunteer.display_name
      end

      click_on "Status"
      find(:css, 'input[data-value="true"]').set(false)
      expect(page).to have_text("No matching records found")

      find(:css, 'input[data-value="false"]').set(true)
      inactive_volunteers.each do |inactive_volunteer|
        expect(page).to have_text inactive_volunteer.display_name
      end
      expect(page.all("table#volunteers tbody tr").count).to eq inactive_volunteers.count

      visit volunteers_path
      click_on "Supervisor"
      find(:css, "#unassigned-vol-filter").set(false)
      assigned_volunteers.each do |assigned_volunteer|
        expect(page).to have_text assigned_volunteer.display_name
      end
      expect(page.all("table#volunteers tbody tr").count).to eq assigned_volunteers.count
    end

    it "can go to the volunteer edit page from the volunteer list", js: true do
      create(:volunteer, :with_assigned_supervisor, casa_org: organization)
      sign_in admin

      visit volunteers_path

      within "#volunteers" do
        click_on "Edit"
      end

      expect(page).to have_text("Editing Volunteer")
    end

    it "can go to the new volunteer page" do
      sign_in admin

      visit volunteers_path

      click_on "New Volunteer"

      expect(page).to have_text("New Volunteer")
      expect(page).to have_css("form#new_volunteer")
    end

    describe "supervisor column of volunteers table" do
      it "is blank when volunteer has no supervisor", js: true do
        create(:volunteer, casa_org: organization)
        sign_in admin

        visit volunteers_path
        click_on "Supervisor"
        find(:css, "#unassigned-vol-filter").set(true)
        supervisor_cell = page.find("tbody .supervisor-column")

        expect(supervisor_cell.text).to eq ""
      end

      it "displays supervisor's name when volunteer has supervisor", js: true do
        name = "Superduper Visor"
        supervisor = create(:supervisor, display_name: name, casa_org: organization)
        create(:volunteer, supervisor: supervisor, casa_org: organization)
        sign_in admin

        visit volunteers_path
        supervisor_cell = page.find("tbody .supervisor-column")

        expect(supervisor_cell.text).to eq name
      end

      it "is blank when volunteer's supervisor is inactive", js: true do
        create(:volunteer, :with_inactive_supervisor, casa_org: organization)
        sign_in admin

        visit volunteers_path
        click_on "Supervisor"
        find(:css, "#unassigned-vol-filter").set(true)
        supervisor_cell = page.find("tbody .supervisor-column")

        expect(supervisor_cell.text).to eq ""
      end
    end

    describe "Manage Volunteers button" do
      let!(:volunteers) {
        [
          create(:volunteer, casa_org: organization),
          create(:volunteer, casa_org: organization),
          create(:volunteer, casa_org: organization)
        ]
      }

      before do
        sign_in admin
      end

      it "does not display by default" do
        visit volunteers_path
        expect(page).not_to have_text "Manage Volunteer"
      end

      context "when one or more volunteers selected" do
        it "is displayed" do
          visit volunteers_path
          find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}", wait: 3).click

          expect(page).to have_text "Manage Volunteer"
        end

        it "displays number of volunteers selected" do
          visit volunteers_path
          volunteers.each_with_index do |volunteer, index|
            find("#supervisor_volunteer_volunteer_ids_#{volunteer.id}", wait: 3).click
            button = find("[data-select-all-target='buttonLabel']")
            expect(button).to have_text "(#{index + 1})"
          end
        end

        it "text matches pluralization of volunteers selected" do
          visit volunteers_path
          find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}", wait: 3).click
          expect(page).not_to have_text "Manage Volunteers"

          find("#supervisor_volunteer_volunteer_ids_#{volunteers[1].id}").click
          expect(page).to have_text "Manage Volunteers"
        end

        it "is hidden when all volunteers unchecked" do
          visit volunteers_path
          find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}", wait: 3).click
          expect(page).to have_text "Manage Volunteer"

          find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}").click
          expect(page).not_to have_text "Manage Volunteer"
        end
      end
    end

    describe "Select All Checkbox" do
      let!(:volunteers) {
        [
          create(:volunteer, casa_org: organization),
          create(:volunteer, casa_org: organization),
          create(:volunteer, casa_org: organization)
        ]
      }

      before do
        sign_in admin
        visit volunteers_path
        find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}") # wait for volunteers to be displayed
      end

      it "selects all volunteers" do
        find("[data-select-all-target='checkboxAll']").click

        volunteers.each do |volunteer|
          expect(find("#supervisor_volunteer_volunteer_ids_#{volunteer.id}").checked?).to be true
        end
      end

      context "when all are checked" do
        before do
          volunteers.each do |volunteer|
            find("#supervisor_volunteer_volunteer_ids_#{volunteer.id}").click
          end
        end

        it "deselects all volunteers" do
          find("[data-select-all-target='checkboxAll']").click

          volunteers.each do |volunteer|
            expect(find("#supervisor_volunteer_volunteer_ids_#{volunteer.id}").checked?).to be false
          end
        end
      end

      context "when some are checked" do
        before do
          find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}").click
        end

        it "is semi-checked (indeterminate)" do
          expect(find("[data-select-all-target='checkboxAll']").checked?).to be false
          expect(find("[data-select-all-target='checkboxAll']")[:indeterminate]).to eq("true")
        end

        it "selects all volunteers" do
          find("[data-select-all-target='checkboxAll']").click

          volunteers.each do |volunteer|
            expect(find("#supervisor_volunteer_volunteer_ids_#{volunteer.id}").checked?).to be true
          end
        end
      end
    end

    describe "Select Supervisor Modal Submit button" do
      let!(:volunteer) { create(:volunteer, casa_org: organization) }
      let!(:supervisor) { create(:supervisor, casa_org: organization) }

      before do
        sign_in admin
      end

      it "is disabled by default" do
        visit volunteers_path
        find("#supervisor_volunteer_volunteer_ids_#{volunteer.id}", wait: 3).click
        find("[data-select-all-target='button']").click

        button = find("[data-disable-form-target='submitButton']")
        expect(button.disabled?).to be true
        expect(button[:class].include?("deactive-btn")).to be true
        expect(button[:class].include?("dark-btn")).to be false
        expect(button[:class].include?("btn-hover")).to be false
      end

      context "when none is selected" do
        it "is enabled" do
          visit volunteers_path
          find("#supervisor_volunteer_volunteer_ids_#{volunteer.id}", wait: 3).click
          find("[data-select-all-target='button']").click
          select "None", from: "supervisor_volunteer_supervisor_id"

          button = find("[data-disable-form-target='submitButton']")

          expect(button.disabled?).to be false
          expect(button[:class].include?("deactive-btn")).to be false
          expect(button[:class].include?("dark-btn")).to be true
          expect(button[:class].include?("btn-hover")).to be true
        end
      end

      context "when a supervisor is selected" do
        it "is enabled" do
          visit volunteers_path
          find("#supervisor_volunteer_volunteer_ids_#{volunteer.id}", wait: 3).click
          find("[data-select-all-target='button']").click

          select supervisor.display_name, from: "supervisor_volunteer_supervisor_id"
          button = find("[data-disable-form-target='submitButton']")
          expect(button.disabled?).to be false
          expect(button[:class].include?("deactive-btn")).to be false
          expect(button[:class].include?("dark-btn")).to be true
          expect(button[:class].include?("btn-hover")).to be true
        end
      end

      context "when Choose a supervisor is selected" do
        it "is disabled" do
          visit volunteers_path
          find("#supervisor_volunteer_volunteer_ids_#{volunteer.id}", wait: 3).click
          find("[data-select-all-target='button']").click

          select supervisor.display_name, from: "supervisor_volunteer_supervisor_id"
          select "Choose a supervisor", from: "supervisor_volunteer_supervisor_id"
          button = find("[data-disable-form-target='submitButton']")
          expect(button.disabled?).to be true
          expect(button[:class].include?("deactive-btn")).to be true
          expect(button[:class].include?("dark-btn")).to be false
          expect(button[:class].include?("btn-hover")).to be false
        end
      end
    end
  end

  context "supervisor user" do
    let(:supervisor) { create(:supervisor, casa_org: organization) }
    let(:input_field) { "div#volunteers_filter input" }

    it "can filter volunteers", js: true do
      active_volunteers = create_list(:volunteer, 3, :with_assigned_supervisor, casa_org: organization)
      active_volunteers[2].supervisor = supervisor

      inactive_volunteers = create_list(:volunteer, 2, :with_assigned_supervisor, :inactive, casa_org: organization)
      inactive_volunteers[0].supervisor = supervisor
      inactive_volunteers[1].supervisor = supervisor

      sign_in supervisor

      visit volunteers_path
      expect(page).to have_selector(".volunteer-filters")

      expect(page.all("table#volunteers tbody tr").count).to eq 1

      click_on "Status"
      find(:css, 'input[data-value="true"]').set(false)
      expect(page).to have_text("No matching records found")

      find(:css, 'input[data-value="false"]').set(true)
      inactive_volunteers.each do |inactive_volunteer|
        expect(page).to have_text inactive_volunteer.display_name
      end
      expect(page.all("table#volunteers tbody tr").count).to eq inactive_volunteers.count
    end

    it "can show/hide columns on volunteers table", js: true do
      travel_to Date.new(2021, 1, 1)
      sign_in supervisor

      visit volunteers_path
      expect(page).to have_text("Pick displayed columns")

      click_on "Pick displayed columns"
      expect(page).to have_text("Name")
      expect(page).to have_text("Status")
      expect(page).to have_text("Contact Made In Past 60 Days")
      expect(page).to have_text("Last Attempted Contact")
      check "Name"
      check "Status"
      uncheck "Contact Made In Past 60 Days"
      uncheck "Last Attempted Contact"
      within(".modal-dialog") do
        click_button "Close"
      end

      expect(page).to have_text("Name")
      expect(page).to have_text("Status")
      within("#volunteers") do
        expect(page).to have_no_text("Contact Made In Past 60 Days")
        expect(page).to have_no_text("Last Attempted Contact")
      end
    end

    it "can persist 'show/hide' column preference settings", js: true do
      sign_in supervisor

      visit volunteers_path

      expect(page).to have_text("Pick displayed columns")
      within("#volunteers") do
        expect(page).to have_text("Name")
        expect(page).to have_text("Email")
        expect(page).to have_text("Status")
        expect(page).to have_text("Assigned To Transition Aged Youth")
        expect(page).to have_text("Case Number(s)")
        expect(page).to have_text("Last Attempted Contact")
        expect(page).to have_text("Contacts Made in Past 60 Day")
      end

      click_button "Pick displayed columns"

      uncheck "Name"
      uncheck "Status"
      uncheck "Contact Made In Past 60 Days"
      uncheck "Last Attempted Contact"

      within(".modal-dialog") do
        click_button "Close"
      end

      within("#volunteers") do
        expect(page).to have_no_text("Name")
        expect(page).to have_no_text("Status")
        expect(page).to have_no_text("Contact Made In Past 60 Days")
        expect(page).to have_no_text("Last Attempted Contact")
        expect(page).to have_text("Email")
        expect(page).to have_text("Assigned To Transition Aged Youth")
        expect(page).to have_text("Case Number(s)")
      end

      sign_out supervisor
      visit volunteers_path

      sign_in supervisor
      visit volunteers_path

      # Expectations after page reload
      within("#volunteers") do
        expect(page).to have_no_text("Name")
        expect(page).to have_no_text("Status")
        expect(page).to have_no_text("Contact Made In Past 60 Days")
        expect(page).to have_no_text("Last Attempted Contact")
        expect(page).to have_text("Email")
        expect(page).to have_text("Assigned To Transition Aged Youth")
        expect(page).to have_text("Case Number(s)")
      end
    end

    context "with volunteers" do
      let(:supervisor) { create(:supervisor, :with_volunteers) }

      it "Search history is clean after navigating away from volunteers view", js: true do
        sign_in supervisor
        visit volunteers_path

        page.find(input_field).set("Test")

        visit supervisors_path
        visit volunteers_path
        input_search = page.find(input_field)
        expect(input_search.value).to eq("")
      end
    end
  end
end
