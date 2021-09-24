require "rails_helper"

RSpec.describe "supervisors/index", type: :system do
  shared_examples_for "functioning sort buttons" do
    it "sorts table columns" do
      expect(page).to have_selector("tr:nth-child(1)", text: expected_first_ordered_value)

      find("th", text: column_to_sort).click

      expect(page).to have_selector("th.sorting_asc", text: column_to_sort)
      expect(page).to have_selector("tr:nth-child(1)", text: expected_last_ordered_value)
    end
  end

  let(:organization) { build(:casa_org) }
  let(:supervisor_user) { create(:supervisor, casa_org: organization) }

  before { sign_in supervisor_user }

  context "when editing supervisor" do
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

    before(:each) do
      # Stub our `@supervisors` collection so we've got control over column values for sorting.
      allow_any_instance_of(SupervisorPolicy::Scope).to receive(:resolve).and_return(
        [first_supervisor, last_supervisor]
      )

      allow(first_supervisor).to receive(:volunteers_serving_transition_aged_youth).and_return(9)
      allow(first_supervisor).to receive(:no_attempt_for_two_weeks).and_return(9)
      allow(first_supervisor).to receive(:volunteers).and_return(Array.new(9))

      allow(last_supervisor).to receive(:active_volunteers).and_return(11)
      allow(last_supervisor).to receive(:volunteers_serving_transition_aged_youth).and_return(11)
      allow(last_supervisor).to receive(:no_attempt_for_two_weeks).and_return(11)

      sign_in supervisor_user
      visit supervisors_path
    end

    context "when sorting supervisors" do
      let(:expected_first_ordered_value) { "11" }
      let(:expected_last_ordered_value) { "9" }

      it "by supervisor name", js: true do
        expect(page).to have_selector("th.sorting_desc", text: "Supervisor Name")
        expect(page).to have_selector("tr:nth-child(1)", text: "Last Supervisor")

        find("th", text: "Supervisor Name").click

        expect(page).to have_selector("th.sorting_asc", text: "Supervisor Name")
        expect(page).to have_selector("tr:nth-child(1)", text: "First Supervisor")
      end

      describe "by volunteer count", js: true do
        let(:column_to_sort) { "Volunteer Assignments" }

        it_behaves_like "functioning sort buttons"
      end

      describe "by transition-aged youth", js: true do
        let(:column_to_sort) { "Serving Transition Aged Youth" }

        it_behaves_like "functioning sort buttons"
      end

      describe "by no-contact count", js: true do
        let(:column_to_sort) { "No Contact (14 days)" }

        it_behaves_like "functioning sort buttons"
      end
    end

    context "with unassigned volunteers" do
      let(:unassigned_volunteer_name) { "Tony Ruiz" }
      let!(:unassigned_volunteer) { create(:volunteer, casa_org: organization, display_name: unassigned_volunteer_name) }

      before do
        sign_in supervisor_user
        visit supervisors_path
      end

      it "will show a list of unassigned volunteers" do
        expect(page).to have_text("Active volunteers not assigned to supervisors")
        expect(page).to have_text("Assigned to Case(s)")
        expect(page).to have_text(unassigned_volunteer_name)

        expect(page).not_to have_text("There are no unassigned volunteers")
      end

      it "links to edit page of volunteer" do
        click_on unassigned_volunteer_name
        expect(page).to have_current_path("/volunteers/#{unassigned_volunteer.id}/edit")
      end
    end

    context "without unassigned volunteers" do
      before do
        sign_in supervisor_user
        visit supervisors_path
      end

      it "will not show a list of volunteers not assigned to supervisors" do
        expect(page).to have_text("There are no active volunteers without supervisors to display here")

        expect(page).not_to have_text("Active volunteers not assigned to supervisors")
        expect(page).not_to have_text("Assigned to Case(s)")
      end
    end
  end

  context "with inactive volunteers assigned" do
    let!(:active_volunteer) do
      create(
        :volunteer,
        :with_casa_cases,
        :with_assigned_supervisor,
        supervisor: supervisor_user,
        casa_org: organization
      )
    end

    let!(:inactive_volunteer) do
      create(
        :volunteer,
        :inactive,
        :with_assigned_supervisor,
        supervisor: supervisor_user,
        casa_org: organization
      )
    end

    before do
      sign_in supervisor_user
      visit supervisors_path
    end

    it "count only active volunteers" do
      within "td#volunteer-assignments-#{supervisor_user.id}" do
        expect(page).to have_content("1")
      end
    end
  end
end
