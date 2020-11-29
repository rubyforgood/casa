require "rails_helper"

RSpec.describe "supervisors/edit", type: :system do
  let(:organization) { create(:casa_org) }

  context "logged in as an admin" do
    let(:user) { create(:casa_admin, casa_org: organization) }

    it "can edit supervisor by clicking on the edit link from the supervisors list page" do
      supervisor_name = "Leslie Knope"
      create(:supervisor, display_name: supervisor_name, casa_org: organization)
      sign_in user

      visit supervisors_path

      expect(page).to have_text(supervisor_name)

      within "#supervisors" do
        click_on "Edit"
      end

      expect(page).to have_text("Editing Supervisor")
    end

    it "can edit supervisor by clicking on the supervisor's name from the supervisors list page" do
      supervisor_name = "Leslie Knope"
      create(:supervisor, display_name: supervisor_name, casa_org: organization)
      sign_in user

      visit supervisors_path

      within "#supervisors" do
        click_on supervisor_name
      end

      expect(page).to have_text("Editing Supervisor")
    end

    it "can go to the supervisor edit page and see red message when there are no active volunteers" do
      supervisor = create :supervisor, casa_org: organization

      sign_in user

      visit edit_supervisor_path(supervisor)

      expect(page).to have_text("There are no active, unassigned volunteers available")
    end

    context "when entering valid information" do
      it "updates the e-mail address successfully" do
        sign_in user
        supervisor = create(:supervisor)
        visit edit_supervisor_path(supervisor)

        expect {
          fill_in "supervisor_email", with: ""
          fill_in "supervisor_email", with: "new" + supervisor.email
          click_on "Submit"
          page.find ".header-flash > div"
          supervisor.reload
        }.to change { supervisor.email }.to "new" + supervisor.email
      end
    end

    context "when the email exists already" do
      let!(:existing_supervisor) { create(:supervisor) }

      it "responds with a notice" do
        sign_in user
        supervisor = create(:supervisor)
        visit edit_supervisor_path(supervisor)
        fill_in "supervisor_email", with: ""
        fill_in "supervisor_email", with: existing_supervisor.email
        click_on "Submit"

        within "#error_explanation" do
          expect(page).to have_content(/already been taken/i)
        end
      end
    end
  end

  context "logged in as a supervisor" do
    before do
      sign_in user
      visit edit_supervisor_path(supervisor)
    end

    context "when editing other supervisor" do
      let(:user) { create(:supervisor, casa_org: organization) }
      let(:supervisor) { create(:supervisor, casa_org: organization) }

      it "sees red message when there are no active volunteers" do
        expect(page).to have_text("There are no active, unassigned volunteers available")
      end

      it "does not have a submit button" do
        expect(page).not_to have_selector(:link_or_button, "Submit")
      end
    end

    context "when editing own page" do
      let(:supervisor) { create(:supervisor, casa_org: organization) }
      let(:user) { supervisor }

      it "displays a submit button" do
        visit edit_supervisor_path(supervisor)

        expect(page).to have_selector(:link_or_button, "Submit")
      end

      context "when no volunteers exist" do
        let!(:volunteer_1) { create(:volunteer, display_name: "AAA", casa_org: organization) }

        it "does not error out when adding non-existent volunteer" do
          visit edit_supervisor_path(supervisor)
          click_on "Assign Volunteer"
          click_on "Assign Volunteer"
          expect(page).to have_text("There are no active, unassigned volunteers available.")
        end
      end
    end
  end
end
