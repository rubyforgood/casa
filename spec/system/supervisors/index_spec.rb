require "rails_helper"

RSpec.describe "supervisors/index", :disable_bullet, type: :system do
  let(:organization) { create(:casa_org) }
  let(:user) { create(:supervisor, casa_org: organization) }

  it "can edit supervisor by clicking on the edit link from the supervisors list page" do
    supervisor_name = "Leslie Knope"
    create(:supervisor, display_name: supervisor_name, casa_org: organization)
    sign_in user

    visit supervisors_path

    expect(page).to have_text(supervisor_name)

    within "#supervisors" do
      click_on "Edit", match: :first
    end

    expect(page).to have_text("Editing Supervisor")
  end

  it "can edit supervisor by clicking on the supervisor's name from the supervisors list page" do
    supervisor_name = "Leslie Knope"
    create(:supervisor, display_name: supervisor_name, casa_org: organization)
    sign_in user

    visit supervisors_path

    within "#supervisors" do
      click_on supervisor_name, match: :first
    end

    expect(page).to have_text("Editing Supervisor")
  end

  describe "can sort table columns" do
    def verify_numeric_sort(column)
      expect(page).to have_selector("tr:nth-child(1)", text: "11")

      find("th", text: column).click

      expect(page).to have_selector("th.sorting_asc", text: column)
      expect(page).to have_selector("tr:nth-child(1)", text: "9")
    end

    let!(:first_supervisor) { create(:supervisor, display_name: "First Supervisor", casa_org: organization) }
    let!(:last_supervisor) { create(:supervisor, display_name: "Last Supervisor", casa_org: organization) }

    before(:each) do
      # Stub our `@supervisors` collection so we've got control over column values for sorting.
      allow_any_instance_of(SupervisorPolicy::Scope).to receive(:resolve).and_return(
        [first_supervisor, last_supervisor]
      )

      allow(first_supervisor).to receive(:active_volunteers).and_return(9)
      allow(first_supervisor).to receive(:volunteers_serving_transition_aged_youth).and_return(9)
      allow(first_supervisor).to receive(:no_contact_for_two_weeks).and_return(9)

      allow(last_supervisor).to receive(:active_volunteers).and_return(11)
      allow(last_supervisor).to receive(:volunteers_serving_transition_aged_youth).and_return(11)
      allow(last_supervisor).to receive(:no_contact_for_two_weeks).and_return(11)

      sign_in user
      visit supervisors_path
    end

    it "by supervisor name", js: true do
      expect(page).to have_selector("th.sorting_desc", text: "Supervisor Name")
      expect(page).to have_selector("tr:nth-child(1)", text: "Last Supervisor")

      find("th", text: "Supervisor Name").click

      expect(page).to have_selector("th.sorting_asc", text: "Supervisor Name")
      expect(page).to have_selector("tr:nth-child(1)", text: "First Supervisor")
    end

    it "by volunteer count", js: true do
      verify_numeric_sort("Volunteer Assignments")
    end

    it "by transition-aged youth", js: true do
      verify_numeric_sort("Serving Transition Aged Youth")
    end

    it "by no-contact count", js: true do
      verify_numeric_sort("No Contact (14 days)")
    end

    context "with unassigned volunteers" do
      let!(:unassigned_volunteer) { create(:volunteer, casa_org: organization, display_name: "Tony Ruiz") }

      before do
        sign_in user
        visit supervisors_path
      end

      it "will show a list of unassigned volunteers" do
        expect(page).to have_text("Active volunteers not assigned to supervisors")
        expect(page).to have_text("Assigned to Case(s)")
        expect(page).to have_text("Tony Ruiz")
        expect(page).not_to have_text("There are no unassigned volunteers")
      end

      it "links to edit page of volunteer" do
        click_on("Tony Ruiz")
        expect(page).to have_current_path("/volunteers/#{Volunteer.find_by(display_name: "Tony Ruiz").id}/edit")
      end
    end

    context "without unassigned volunteers" do
      before do
        sign_in user
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
    before do
      volunteer = create(:volunteer, :with_casa_cases, casa_org: organization)
      FactoryBot.create(:supervisor_volunteer, supervisor: user, volunteer: volunteer)

      inactive_volunteer = create(:volunteer, :inactive, casa_org: organization)
      FactoryBot.create(:supervisor_volunteer, supervisor: user, volunteer: inactive_volunteer)

      sign_in user
      visit supervisors_path
    end

    it "count only active volunteers" do
      within "td#volunteer-assignments-#{user.id}" do
        expect(page).to have_content("1")
      end
    end
  end
end
