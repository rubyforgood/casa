require "rails_helper"

RSpec.describe "supervisors/index", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:other_org) { create(:casa_org) }

  describe "the supervisor roster" do
    context "signed in as an admin" do
      before { sign_in admin }

      it "lists active supervisors and links to their edit pages by name" do
        supervisor = create(:supervisor, display_name: "Leslie Knope", casa_org: organization)
        visit supervisors_path

        within "#supervisors" do
          expect(page).to have_text("Leslie Knope")
          click_on "Leslie Knope"
        end

        expect(page).to have_current_path(edit_supervisor_path(supervisor))
        expect(page).to have_text("Edit supervisor")
      end

      it "edits a supervisor from the Edit action" do
        create(:supervisor, display_name: "Leslie Knope", casa_org: organization)
        visit supervisors_path

        within("#supervisors") { click_on "Edit", match: :first }

        expect(page).to have_text("Edit supervisor")
      end

      it "does not show supervisors from other organizations" do
        create(:supervisor, display_name: "In My Org", casa_org: organization)
        create(:supervisor, display_name: "Other Org Supervisor", casa_org: other_org)

        visit supervisors_path

        within "#supervisors" do
          expect(page).to have_text("In My Org")
          expect(page).to have_no_text("Other Org Supervisor")
        end
      end

      it "can access the New Supervisor button" do
        visit supervisors_path

        expect(page).to have_link("New supervisor", href: new_supervisor_path)
      end
    end

    context "signed in as a supervisor" do
      let(:supervisor) { create(:supervisor, casa_org: organization) }

      before { sign_in supervisor }

      it "can view the roster but cannot create a supervisor" do
        visit supervisors_path

        expect(page).to have_css("h1", text: "Supervisors")
        expect(page).to have_no_link("New supervisor", href: new_supervisor_path)
      end
    end
  end

  describe "status filter" do
    let!(:active_supervisor) { create(:supervisor, display_name: "Active Supervisor", casa_org: organization) }
    let!(:inactive_supervisor) { create(:supervisor, :inactive, display_name: "Inactive Supervisor", casa_org: organization) }

    before { sign_in admin }

    it "defaults to active supervisors" do
      visit supervisors_path

      within "#supervisors" do
        expect(page).to have_text("Active Supervisor")
        expect(page).to have_no_text("Inactive Supervisor")
      end
    end

    it "shows inactive supervisors when filtered to inactive" do
      visit supervisors_path(status: "inactive")

      within "#supervisors" do
        expect(page).to have_text("Inactive Supervisor")
        expect(page).to have_no_text("Active Supervisor")
      end
    end

    it "shows both when filtered to all" do
      visit supervisors_path(status: "all")

      within "#supervisors" do
        expect(page).to have_text("Active Supervisor")
        expect(page).to have_text("Inactive Supervisor")
      end
    end

    it "submits the filter on change", :js do
      visit supervisors_path

      within "#supervisors" do
        expect(page).to have_text("Active Supervisor")
        expect(page).to have_no_text("Inactive Supervisor")
      end

      select "Inactive", from: "Status"

      within "#supervisors" do
        expect(page).to have_text("Inactive Supervisor")
        expect(page).to have_no_text("Active Supervisor")
      end
    end
  end

  describe "volunteer contact stats" do
    before { sign_in admin }

    it "shows attempting and not-attempting counts for a supervisor's volunteers" do
      supervisor = create(:supervisor, display_name: "Stat Supervisor", casa_org: organization)
      create(:volunteer, :with_cases_and_contacts, supervisor: supervisor, casa_org: organization)
      create(:volunteer, :with_casa_cases, supervisor: supervisor, casa_org: organization)

      visit supervisors_path

      row = find("#supervisor-#{supervisor.id}-information")
      expect(row).to have_css("[data-stat='attempting']", text: "1")
      expect(row).to have_css("[data-stat='not-attempting']", text: "1")
    end

    it "shows a no-assigned-volunteers message for a supervisor with none" do
      supervisor = create(:supervisor, display_name: "Empty Supervisor", casa_org: organization)

      visit supervisors_path

      row = find("#supervisor-#{supervisor.id}-information")
      expect(row).to have_css("[data-stat='no-volunteers']")
      expect(row).to have_text("No assigned volunteers")
    end
  end

  describe "volunteers without supervisors" do
    before { sign_in admin }

    it "lists active unassigned volunteers and links to their edit pages" do
      volunteer = create(:volunteer, display_name: "Tony Ruiz", casa_org: organization)

      visit supervisors_path

      expect(page).to have_text("Volunteers without supervisors")
      expect(page).to have_text("Tony Ruiz")

      click_on "Tony Ruiz"
      expect(page).to have_current_path(edit_volunteer_path(volunteer))
    end

    it "shows an empty message when every volunteer has a supervisor" do
      create(:volunteer, :with_assigned_supervisor, casa_org: organization)

      visit supervisors_path

      expect(page).to have_text("There are no active volunteers without supervisors to display here")
    end
  end

  describe "CASA cases without court dates" do
    before { sign_in admin }

    it "lists cases missing a court date" do
      casa_case = create(:casa_case, case_number: "CINA-1", casa_org: organization, court_dates: [])

      visit supervisors_path

      expect(page).to have_text("CASA cases without court dates")
      within "[data-test='cases-without-court-dates']" do
        expect(page).to have_link("CINA-1", href: casa_case_path(casa_case))
      end
    end
  end
end
