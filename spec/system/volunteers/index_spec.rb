require "rails_helper"

RSpec.describe "volunteers/index", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let!(:supervisor) { create(:supervisor, display_name: "Sam Supervisor", casa_org: organization) }

  describe "listing and navigation" do
    it "lists active volunteers and links to their assigned cases" do
      volunteer = create(:volunteer, display_name: "User One", email: "casa@example.com", casa_org: organization, supervisor: supervisor)
      casa_case = create(:casa_case, casa_org: organization, birth_month_year_youth: CasaCase::TRANSITION_AGE.years.ago)
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

      sign_in admin
      visit volunteers_path

      expect(page).to have_text("User One")
      within "#volunteers" do
        expect(page).to have_link(casa_case.case_number)
        click_on casa_case.case_number
      end

      expect(page).to have_text("Case #{casa_case.case_number}")
    end

    it "shows the last attempted contact column" do
      create(:volunteer, casa_org: organization, supervisor: supervisor)

      sign_in admin
      visit volunteers_path

      expect(page).to have_text("Last attempted contact")
    end

    it "goes to the volunteer edit page" do
      create(:volunteer, casa_org: organization, supervisor: supervisor)
      sign_in admin

      visit volunteers_path
      within "#volunteers" do
        click_on "Edit"
      end

      expect(page).to have_text("Edit volunteer")
    end

    it "goes to the new volunteer page" do
      sign_in admin

      visit volunteers_path
      click_on "New Volunteer"

      expect(page).to have_text("New Volunteer")
      expect(page).to have_css("form#new_volunteer")
    end
  end

  describe "supervisor column" do
    it "displays the supervisor's name" do
      s = create(:supervisor, display_name: "Superduper Visor", casa_org: organization)
      create(:volunteer, supervisor: s, casa_org: organization)

      sign_in admin
      visit volunteers_path

      expect(page).to have_css("#volunteers .supervisor-column", text: "Superduper Visor")
    end

    it "is blank when the volunteer has no supervisor" do
      create(:volunteer, display_name: "Lonewolf Vol", casa_org: organization)

      sign_in admin
      visit volunteers_path(supervisor: "unassigned")

      expect(page).to have_text("Lonewolf Vol")
      expect(page).to have_css("#volunteers .supervisor-column", text: "")
    end

    it "does not show an inactive supervisor's name" do
      inactive_sup = create(:supervisor, display_name: "Ghost Supervisor", active: false, casa_org: organization)
      create(:volunteer, supervisor: inactive_sup, casa_org: organization)

      sign_in admin
      visit volunteers_path

      expect(page).to have_no_text("Ghost Supervisor")
    end
  end

  describe "filtering" do
    it "filters by status" do
      create(:volunteer, display_name: "Active Vol", casa_org: organization, supervisor: supervisor)
      create(:volunteer, :inactive, display_name: "Inactive Vol", casa_org: organization)

      sign_in admin

      visit volunteers_path
      expect(page).to have_text("Active Vol")
      expect(page).to have_no_text("Inactive Vol")

      visit volunteers_path(status: "inactive")
      expect(page).to have_text("Inactive Vol")
      expect(page).to have_no_text("Active Vol")

      visit volunteers_path(status: "all")
      expect(page).to have_text("Active Vol")
      expect(page).to have_text("Inactive Vol")
    end

    it "shows an empty state when nothing matches" do
      create(:volunteer, :inactive, casa_org: organization)

      sign_in admin
      visit volunteers_path

      expect(page).to have_text("No volunteers found")
    end

    it "filters by supervisor assignment" do
      create(:volunteer, display_name: "Assigned Vol", casa_org: organization, supervisor: supervisor)
      create(:volunteer, display_name: "Unassigned Vol", casa_org: organization)

      sign_in admin

      visit volunteers_path(supervisor: "unassigned")
      expect(page).to have_text("Unassigned Vol")
      expect(page).to have_no_text("Assigned Vol")

      visit volunteers_path(supervisor: supervisor.id)
      expect(page).to have_text("Assigned Vol")
      expect(page).to have_no_text("Unassigned Vol")
    end

    it "searches by name" do
      create(:volunteer, display_name: "Findable Person", casa_org: organization, supervisor: supervisor)
      create(:volunteer, display_name: "Someone Else", casa_org: organization, supervisor: supervisor)

      sign_in admin
      visit volunteers_path(search: "Findable")

      expect(page).to have_text("Findable Person")
      expect(page).to have_no_text("Someone Else")
    end

    it "submits the filter on change", :js do
      create(:volunteer, display_name: "Active Vol", casa_org: organization, supervisor: supervisor)
      create(:volunteer, :inactive, display_name: "Inactive Vol", casa_org: organization)

      sign_in admin
      visit volunteers_path
      expect(page).to have_css(".volunteer-filters")

      select "Inactive", from: "Status"

      expect(page).to have_text("Inactive Vol")
      expect(page).to have_no_text("Active Vol")
    end
  end

  describe "bulk supervisor assignment", :js do
    let!(:volunteers) { create_list(:volunteer, 2, casa_org: organization) }

    before do
      sign_in admin
      visit volunteers_path
    end

    it "hides the manage button until a volunteer is selected" do
      expect(page).to have_no_text("Manage Volunteer")

      find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}").click
      expect(page).to have_text("Manage Volunteer")
    end

    it "pluralizes the label with the selected count" do
      find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}").click
      expect(page).to have_text("Manage Volunteer (1)")

      find("#supervisor_volunteer_volunteer_ids_#{volunteers[1].id}").click
      expect(page).to have_text("Manage Volunteers (2)")
    end

    it "hides the button again when the last volunteer is deselected" do
      find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}").click
      expect(page).to have_text("Manage Volunteer")

      find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}").click
      expect(page).to have_no_text("Manage Volunteer")
    end

    describe "select-all checkbox" do
      it "selects and deselects every volunteer" do
        find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}") # wait for table
        find("#checkbox-toggle-all").click
        volunteers.each { |v| expect(page).to have_field("supervisor_volunteer_volunteer_ids_#{v.id}", checked: true) }

        find("#checkbox-toggle-all").click
        volunteers.each { |v| expect(page).to have_field("supervisor_volunteer_volunteer_ids_#{v.id}", checked: false) }
      end

      it "is indeterminate when only some are checked" do
        find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}").click

        expect(page).to have_field("checkbox-toggle-all", checked: false)
        expect(find("#checkbox-toggle-all")[:indeterminate]).to eq("true")
      end
    end

    describe "confirm button" do
      before do
        find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}").click
        find("[data-select-all-target='button']").click
      end

      it "is disabled by default" do
        expect(page).to have_button("Confirm", disabled: true)
      end

      it "enables when a supervisor is chosen" do
        select supervisor.display_name, from: "supervisor_volunteer_supervisor_id"
        expect(page).to have_button("Confirm", disabled: false)
      end

      it "enables when None is chosen" do
        select "None", from: "supervisor_volunteer_supervisor_id"
        expect(page).to have_button("Confirm", disabled: false)
      end

      it "re-disables when Choose a supervisor is chosen" do
        select supervisor.display_name, from: "supervisor_volunteer_supervisor_id"
        select "Choose a supervisor", from: "supervisor_volunteer_supervisor_id"
        expect(page).to have_button("Confirm", disabled: true)
      end
    end

    it "reassigns the selected volunteers to a supervisor" do
      find("#supervisor_volunteer_volunteer_ids_#{volunteers[0].id}").click
      find("[data-select-all-target='button']").click
      select supervisor.display_name, from: "supervisor_volunteer_supervisor_id"
      click_on "Confirm"

      expect(page).to have_text("successfully assigned to new supervisor")
      expect(volunteers[0].reload.supervisor).to eq(supervisor)
    end
  end

  context "as a supervisor" do
    it "can view and filter the roster" do
      create(:volunteer, display_name: "Roster Vol", casa_org: organization, supervisor: supervisor)
      create(:volunteer, :inactive, display_name: "Roster Inactive", supervisor: supervisor, casa_org: organization)

      sign_in supervisor

      visit volunteers_path
      expect(page).to have_css(".volunteer-filters")
      expect(page).to have_text("Roster Vol")
      expect(page).to have_no_text("Roster Inactive")

      visit volunteers_path(status: "inactive")
      expect(page).to have_text("Roster Inactive")
    end
  end
end
