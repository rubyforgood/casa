require "rails_helper"

RSpec.describe "supervisors/index", type: :system do
  shared_examples_for "functioning sort buttons" do
    it "sorts table columns" do
      expect(page).to have_css("tr:nth-child(1)", text: expected_first_ordered_value)

      find("th", text: column_to_sort).click

      expect(page).to have_css("th.sorting_asc", text: column_to_sort)
      expect(page).to have_css("tr:nth-child(1)", text: expected_last_ordered_value)
    end
  end

  let(:organization) { build(:casa_org) }
  let(:supervisor_user) { create(:supervisor, casa_org: organization, display_name: "Logged Supervisor") }
  let(:organization_two) { build(:casa_org) }
  let(:supervisor_other_org) { create(:supervisor, casa_org: organization_two, display_name: "No Volunteers Org") }
  let(:other_supervisor) { create(:supervisor, casa_org: organization, display_name: "Other Supervisor") }
  let(:only_contacts_supervisor) { create(:supervisor, casa_org: organization, display_name: "Only Contacts Supervisor") }
  let(:no_contacts_supervisor) { create(:supervisor, casa_org: organization, display_name: "No Contacts Supervisor") }
  let(:no_active_volunteers_supervisor) { create(:supervisor, casa_org: organization, display_name: "No Active Volunteers Supervisor") }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  context "when signed in as a supervisor" do
    before { sign_in supervisor_user }

    context "when editing supervisor", :js do
      let(:supervisor_name) { "Leslie Knope" }
      let!(:supervisor) { create(:supervisor, display_name: supervisor_name, casa_org: organization) }

      before { visit supervisors_path }

      it "can edit supervisor by clicking on the edit link from the supervisors list page" do
        expect(page).to have_text(supervisor_name)

        within "#supervisors" do
          click_on "Edit", match: :first
        end

        expect(page).to have_text("Editing Supervisor")
      end

      it "can edit supervisor by clicking on the supervisor's name from the supervisors list page" do
        expect(page).to have_text(supervisor_name)

        within "#supervisors" do
          click_on supervisor_name
        end

        expect(page).to have_text("Editing Supervisor")
      end
    end

    describe "supervisor table" do
      let!(:first_supervisor) { create(:supervisor, display_name: "First Supervisor", casa_org: organization) }
      let!(:last_supervisor) { create(:supervisor, display_name: "Last Supervisor", casa_org: organization) }
      let!(:active_volunteers_for_first_supervisor) { create_list(:volunteer, 2, supervisor: first_supervisor, casa_org: organization) }
      let!(:active_volunteers_for_last_supervisor) { create_list(:volunteer, 5, supervisor: last_supervisor, casa_org: organization) }
      let!(:deacticated_supervisor) {
        create(:supervisor, :inactive, display_name: "Deactivated supervisor", casa_org: organization)
      }

      before do
        # Stub our `@supervisors` collection so we've got control over column values for sorting.
        allow_any_instance_of(SupervisorPolicy::Scope).to receive(:resolve).and_return(
          Supervisor.where.not(display_name: supervisor_user.display_name).order(display_name: :asc)
        )

        active_volunteers_for_first_supervisor.map { |av|
          casa_case = create(:casa_case, casa_org: av.casa_org)
          create(:case_contact, contact_made: false, occurred_at: 1.week.ago, casa_case_id: casa_case.id)
          create(:case_assignment, casa_case: casa_case, volunteer: av)
        }

        active_volunteers_for_last_supervisor.map { |av|
          casa_case = create(:casa_case, casa_org: av.casa_org)
          create(:case_contact, contact_made: false, occurred_at: 1.week.ago, casa_case_id: casa_case.id)
          create(:case_assignment, casa_case: casa_case, volunteer: av)
        }

        sign_in supervisor_user
        visit supervisors_path
      end

      context "with active and deactivated supervisors" do
        it "shows deactivated supervisor on show button click", :js do
          expect(page).to have_text("Showing 1 to 2 of 2 entries (filtered from 3 total entries)")
          expect(page).to have_no_text("Deactivated supervisor")

          find(".supervisor-filters").click_on("Filter Status")
          check("status_option_inactive")

          expect(page).to have_text("Showing 1 to 3 of 3 entries")
          expect(page).to have_text("Deactivated supervisor")

          uncheck("status_option_inactive")

          expect(page).to have_text("Showing 1 to 2 of 2 entries (filtered from 3 total entries)")
          expect(page).to have_no_text("Deactivated supervisor")
        end
      end

      context "with unassigned volunteers" do
        let(:unassigned_volunteer_name) { "Tony Ruiz" }
        let!(:unassigned_volunteer) { create(:volunteer, casa_org: organization, display_name: unassigned_volunteer_name) }

        before do
          sign_in supervisor_user
          visit supervisors_path
        end

        it "shows a list of unassigned volunteers" do
          expect(page).to have_text("Active volunteers not assigned to supervisors")
          expect(page).to have_text("Assigned to Case(s)")
          expect(page).to have_text(unassigned_volunteer_name)

          expect(page).to have_no_text("There are no unassigned volunteers")
        end

        it "links to edit page of volunteer" do
          click_on unassigned_volunteer_name
          expect(page).to have_current_path("/volunteers/#{unassigned_volunteer.id}/edit")
        end
      end

      context "without unassigned volunteers" do
        before do
          sign_in supervisor_other_org
          visit supervisors_path
        end

        it "does not show a list of volunteers not assigned to supervisors", :js do
          expect(page).to have_text("There are no active volunteers without supervisors to display here")

          expect(page).to have_no_text("Active volunteers not assigned to supervisors")
          expect(page).to have_no_text("Assigned to Case(s)")
        end
      end
    end

    describe "supervisor table filters" do
      let(:supervisor_user) { create(:supervisor, casa_org: organization) }

      before do
        sign_in supervisor_user
        visit supervisors_path
      end

      describe "status", :js do
        let!(:active_supervisor) do
          create(:supervisor, display_name: "Active Supervisor", casa_org: organization, active: true)
        end

        let!(:inactive_supervisor) do
          create(:supervisor, display_name: "Inactive Supervisor", casa_org: organization, active: false)
        end

        context "when only active checked" do
          it "filters the supervisors correctly", :aggregate_failures do
            within(:css, ".supervisor-filters") do
              click_on "Status"
              find(:css, ".active").set(false)
              find(:css, ".active").set(true)
              find(:css, ".inactive").set(false)
            end

            within("table#supervisors") do
              expect(page).to have_text("Active Supervisor")
              expect(page).to have_no_text("Inactive Supervisor")
            end
          end
        end

        context "when only inactive checked" do
          it "filters the supervisors correctly", :aggregate_failures do
            within(:css, ".supervisor-filters") do
              click_on "Status"
              find(:css, ".active").set(false)
              find(:css, ".inactive").set(true)
              click_on "Status"
            end

            within("table#supervisors") do
              expect(page).to have_no_content("Active Supervisor")
              expect(page).to have_content("Inactive Supervisor")
            end
          end
        end

        context "when both checked" do
          it "filters the supervisors correctly", :aggregate_failures do # TODO fix test
            within(:css, ".supervisor-filters") do
              click_on "Status"
              find(:css, ".active").set(true)
              find(:css, ".inactive").set(true)
              click_on "Status"
            end

            within("table#supervisors") do
              expect(page).to have_content("Active Supervisor")
              expect(page).to have_content("Inactive Supervisor")
            end
          end
        end
      end
    end
  end

  context "when signed in as an admin" do
    let!(:no_active_volunteers_supervisor) { create(:supervisor, casa_org: organization, display_name: "No Active Volunteers Supervisor") }

    let!(:no_contact_volunteer) do
      create(
        :volunteer,
        :with_casa_cases,
        :with_assigned_supervisor,
        supervisor: supervisor_user,
        casa_org: organization
      )
    end

    let!(:no_contact_pre_transition_volunteer) do
      create(
        :volunteer,
        :with_pretransition_age_case,
        :with_assigned_supervisor,
        supervisor: supervisor_user,
        casa_org: organization
      )
    end

    let!(:with_contact_volunteer) do
      create(
        :volunteer,
        :with_cases_and_contacts,
        :with_assigned_supervisor,
        supervisor: supervisor_user,
        casa_org: organization
      )
    end

    let!(:active_unassigned) do
      create(
        :volunteer,
        :with_casa_cases,
        casa_org: organization
      )
    end

    let!(:other_supervisor_active_volunteer1) do
      create(
        :volunteer,
        :with_cases_and_contacts,
        :with_assigned_supervisor,
        supervisor: other_supervisor,
        casa_org: organization
      )
    end

    let!(:other_supervisor_active_volunteer2) do
      create(
        :volunteer,
        :with_cases_and_contacts,
        :with_assigned_supervisor,
        supervisor: other_supervisor,
        casa_org: organization
      )
    end

    let!(:other_supervisor_no_contact_volunteer1) do
      create(
        :volunteer,
        :with_casa_cases,
        :with_assigned_supervisor,
        supervisor: other_supervisor,
        casa_org: organization
      )
    end

    let!(:other_supervisor_no_contact_volunteer2) do
      create(
        :volunteer,
        :with_casa_cases,
        :with_assigned_supervisor,
        supervisor: other_supervisor,
        casa_org: organization
      )
    end

    let!(:only_contact_volunteer1) do
      create(
        :volunteer,
        :with_cases_and_contacts,
        :with_assigned_supervisor,
        supervisor: only_contacts_supervisor,
        casa_org: organization
      )
    end

    let!(:only_contact_volunteer2) do
      create(
        :volunteer,
        :with_cases_and_contacts,
        :with_assigned_supervisor,
        supervisor: only_contacts_supervisor,
        casa_org: organization
      )
    end

    let!(:only_contact_volunteer3) do
      create(
        :volunteer,
        :with_cases_and_contacts,
        :with_assigned_supervisor,
        supervisor: only_contacts_supervisor,
        casa_org: organization
      )
    end

    let!(:no_contact_volunteer1) do
      create(
        :volunteer,
        :with_casa_cases,
        :with_assigned_supervisor,
        supervisor: no_contacts_supervisor,
        casa_org: organization
      )
    end

    let!(:no_contact_volunteer2) do
      create(
        :volunteer,
        :with_casa_cases,
        :with_assigned_supervisor,
        supervisor: no_contacts_supervisor,
        casa_org: organization
      )
    end

    before do
      sign_in admin
      visit supervisors_path
    end

    it "shows all active supervisors", :js do
      supervisor_table = page.find("table#supervisors")
      expect(supervisor_table.all("div.supervisor_case_contact_stats").length).to eq(5)
    end

    it "shows the correct volunteers for the first supervisor with both volunteer types", :js do
      supervisor_table = page.find("table#supervisors")
      expect(supervisor_table).to have_text(supervisor_user.display_name.html_safe)

      supervisor_stats = page.find("tr#supervisor-#{supervisor_user.id}-information")
      active_contacts_expected = 1
      no_active_contacts_expected = 2
      transition_aged_youth_expected = 2
      active_contact_element = supervisor_stats.find("span.attempted-contact")
      no_active_contact_element = supervisor_stats.find("span.no-attempted-contact")

      expect(active_contact_element).to have_text(active_contacts_expected)
      expect(active_contact_element.has_css?("pr-#{active_contacts_expected * 15}"))
      expect(no_active_contact_element).to have_text(no_active_contacts_expected)
      expect(no_active_contact_element.has_css?("pl-#{no_active_contacts_expected * 15}"))
      expect(supervisor_stats.find(".status-btn.deactive-bg")).to have_text(transition_aged_youth_expected)
    end

    it "shows the correct volunteers for the second supervisor with both volunteer types", :js do
      supervisor_table = page.find("table#supervisors")
      expect(supervisor_table).to have_text(other_supervisor.display_name.html_safe)

      supervisor_stats = page.find("tr#supervisor-#{other_supervisor.id}-information")
      active_contacts_expected = 2
      no_active_contacts_expected = 2
      transition_aged_youth_expected = 4
      active_contact_element = supervisor_stats.find("span.attempted-contact")
      no_active_contact_element = supervisor_stats.find("span.no-attempted-contact")

      expect(active_contact_element).to have_text(active_contacts_expected)
      expect(active_contact_element.has_css?("pr-#{active_contacts_expected * 15}"))
      expect(no_active_contact_element).to have_text(no_active_contacts_expected)
      expect(no_active_contact_element.has_css?("pl-#{no_active_contacts_expected * 15}"))
      expect(supervisor_stats.find(".status-btn.deactive-bg")).to have_text(transition_aged_youth_expected)
    end

    it "shows the correct element for a supervisor with only contact volunteers", :js do
      supervisor_table = page.find("table#supervisors")
      expect(supervisor_table).to have_text(only_contacts_supervisor.display_name.html_safe)

      supervisor_stats = page.find("tr#supervisor-#{only_contacts_supervisor.id}-information")
      active_contacts_expected = 3
      transition_aged_youth_expected = 3
      active_contact_element = supervisor_stats.find("span.attempted-contact")

      expect { supervisor_stats.find("span.no-attempted-contact") }.to raise_error(Capybara::ElementNotFound)
      expect(active_contact_element).to have_text(active_contacts_expected)
      expect(active_contact_element.has_css?("pl-#{active_contacts_expected * 15}"))
      expect(supervisor_stats.find(".status-btn.deactive-bg")).to have_text(transition_aged_youth_expected)
    end

    it "shows the correct element for a supervisor with only no contact volunteers", :js do
      supervisor_table = page.find("table#supervisors")
      expect(supervisor_table).to have_text(no_contacts_supervisor.display_name.html_safe)

      supervisor_stats = page.find("tr#supervisor-#{no_contacts_supervisor.id}-information")
      no_contacts_expected = 2
      transition_aged_youth_expected = 2
      no_contact_element = supervisor_stats.find("span.no-attempted-contact")

      expect { supervisor_stats.find("span.attempted-contact") }.to raise_error(Capybara::ElementNotFound)
      expect { supervisor_stats.find("span.attmepted-contact-end") }.to raise_error(Capybara::ElementNotFound)
      expect(no_contact_element).to have_text(no_contacts_expected)
      expect(no_contact_element.has_css?("pl-#{no_contacts_expected * 15}"))
      expect(supervisor_stats.find(".status-btn.deactive-bg")).to have_text(transition_aged_youth_expected)
    end

    it "shows the correct text with a supervisor with no assigned volunteers", :js do
      supervisor_table = page.find("table#supervisors")
      expect(supervisor_table).to have_text(no_active_volunteers_supervisor.display_name.html_safe)

      supervisor_no_volunteer_stats = page.find("tr#supervisor-#{no_active_volunteers_supervisor.id}-information")
      expect(supervisor_no_volunteer_stats).to have_text("No assigned volunteers")
      expect(supervisor_no_volunteer_stats.find("span.no-volunteers")).to be_truthy
      expect(supervisor_no_volunteer_stats.find("span.no-volunteers").style("flex-grow")).to eq({"flex-grow" => "1"})
    end
  end
end
