require "rails_helper"

RSpec.describe "supervisors/edit", type: :system do
  let(:organization) { create(:casa_org) }

  context "logged in as an admin" do
    let(:user) { create(:casa_admin, casa_org: organization) }

    it "can edit supervisor by clicking on the edit link from the supervisors list page", js: true do
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

    it "can edit supervisor by clicking on the supervisor's name from the supervisors list page", js: true do
      supervisor_name = "Leslie Knope"
      create(:supervisor, display_name: supervisor_name, casa_org: organization)
      sign_in user

      visit supervisors_path

      within "#supervisors" do
        click_on supervisor_name
      end

      expect(page).to have_text("Editing Supervisor")
    end

    context "with invalid data" do
      let(:role) { "supervisor" }
      let(:supervisor) { create(:supervisor, display_name: "Leslie Knope", casa_org: organization) }
      before do
        sign_in user
        visit edit_supervisor_path(supervisor)
      end
      it_should_behave_like "shows error for invalid phone numbers"

      it "shows error for invalid date of birth" do
        fill_in "Date of birth", with: 5.days.from_now.strftime("%Y/%m/%d")
      end
    end

    it "can go to the supervisor edit page and see red message when there are no active volunteers" do
      supervisor = create :supervisor, casa_org: organization

      sign_in user

      visit edit_supervisor_path(supervisor)

      expect(page).to have_text("There are no active, unassigned volunteers available")
    end

    it "can go to the supervisor edit page and see invite and login info" do
      supervisor = create :supervisor, casa_org: organization

      sign_in user

      visit edit_supervisor_path(supervisor)

      expect(page).to have_text "CASA organization "
      expect(page).to have_text "Added to system "
      expect(page).to have_text "Invitation email sent never"
      expect(page).to have_text "Last logged in"
      expect(page).to have_text "Invitation accepted never"
      expect(page).to have_text "Password reset last sent never"
    end

    it "can deactivate a supervisor", js: true do
      supervisor = create :supervisor, casa_org: organization

      sign_in user
      visit edit_supervisor_path(supervisor)

      dismiss_confirm do
        find("a[href='#{deactivate_supervisor_path(supervisor)}']").click
      end

      accept_confirm do
        find("a[href='#{deactivate_supervisor_path(supervisor)}']").click
      end
      expect(page).to have_text("Supervisor was deactivated on")

      expect(supervisor.reload).not_to be_active
    end

    it "can activate a supervisor" do
      inactive_supervisor = create(:supervisor, casa_org_id: organization.id)
      inactive_supervisor.deactivate

      sign_in user

      visit edit_supervisor_path(inactive_supervisor)

      click_on "Activate supervisor"

      expect(page).not_to have_text("Supervisor was deactivated on")

      expect(inactive_supervisor.reload).to be_active
    end

    it "can resend invitation to a supervisor", js: true do
      supervisor = create :supervisor, casa_org: organization

      sign_in user

      visit edit_supervisor_path(supervisor)

      click_on "Resend Invitation"

      expect(page).to have_content("Invitation sent")

      deliveries = ActionMailer::Base.deliveries
      expect(deliveries.count).to eq(1)
      expect(deliveries.last.subject).to have_text "CASA Console invitation instructions"
    end

    it "can convert the supervisor to an admin", js: true do
      supervisor = create(:supervisor, casa_org_id: organization.id)

      sign_in user

      visit supervisors_path
      visit edit_supervisor_path(supervisor)

      click_on "Change to Admin"

      expect(page).to have_text("Supervisor was changed to Admin.")
      expect(User.find(supervisor.id)).to be_casa_admin
    end

    context "logged in as a supervisor" do
      let(:supervisor) { create(:supervisor) }
      it "can't deactivate a supervisor", js: true do
        supervisor2 = create :supervisor, casa_org: organization

        sign_in supervisor
        visit edit_supervisor_path(supervisor2)

        expect(page).to_not have_text("Deactivate supervisor")
      end

      it "can't activate a supervisor" do
        inactive_supervisor = create(:supervisor, casa_org_id: organization.id)
        inactive_supervisor.deactivate

        sign_in supervisor

        visit edit_supervisor_path(inactive_supervisor)

        expect(page).not_to have_text("Activate supervisor")
      end
    end

    context "when entering valid information" do
      before do
        sign_in user
        @supervisor = create(:supervisor)
        @old_email = @supervisor.email
        visit edit_supervisor_path(@supervisor)
        fill_in "supervisor_email", with: "new_supervisor_email@example.com"
        fill_in "supervisor_phone_number", with: "+14155556876"
        fill_in "supervisor_date_of_birth", with: "2003/05/06"

        click_on "Submit"
        @supervisor.reload
      end

      it "sends a confirmation email to the supervisor and displays current email" do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
        expect(ActionMailer::Base.deliveries.first.body.encoded)
          .to match("You can confirm your account email through the link below:")

        expect(page).to have_text "Supervisor was successfully updated. Confirmation Email Sent."
        expect(page).to have_field("Email", with: @old_email)
        expect(@supervisor.unconfirmed_email).to eq("new_supervisor_email@example.com")
      end

      it "correctly updates the supervisor email once confirmed" do
        @supervisor.confirm
        @supervisor.reload
        visit edit_supervisor_path(@supervisor)

        expect(page).to have_field("Email", with: "new_supervisor_email@example.com")
        expect(@supervisor.old_emails).to match([@old_email])
      end
    end

    context "when entering invalid information" do
      before do
        sign_in user
        @supervisor = create(:supervisor)
        visit edit_supervisor_path(@supervisor)
      end

      it "shows error message for invalid phone number" do
        fill_in "supervisor_phone_number", with: "+1415555676"
        click_on "Submit"
        expect(page).to have_text "Phone number must be 10 digits or 12 digits including country code (+1)"
      end
      it "shows error message for invalid date of birth" do
        fill_in "supervisor_date_of_birth", with: 5.days.from_now.strftime("%Y/%m/%d")
        click_on "Submit"
        expect(page).to have_text "Date of birth must be in the past."
      end
    end

    context "when the email exists already" do
      let!(:existing_supervisor) { create(:supervisor, casa_org_id: organization.id) }

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
      let(:user) { build(:supervisor, casa_org: organization) }
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

      it "sees last invite and login info" do
        expect(page).to have_text "Added to system "
        expect(page).to have_text "Invitation email sent never"
        expect(page).to have_text "Last logged in"
        expect(page).to have_text "Invitation accepted never"
        expect(page).to have_text "Password reset last sent never"
      end

      context "when no volunteers exist" do
        let!(:volunteer_1) { create(:volunteer, display_name: "AAA", casa_org: organization) }

        it "does not error out when adding non-existent volunteer" do
          visit edit_supervisor_path(supervisor)
          select volunteer_1.display_name, from: "Select a Volunteer"
          click_on "Assign Volunteer"
          expect(page.find_button("Assign Volunteer", disabled: true)).to be_present
          expect(page).to have_text("There are no active, unassigned volunteers available.")
        end
      end

      context "when there are assigned volunteers" do
        let(:supervisor) { create(:supervisor, :with_volunteers, casa_org: organization) }

        it "shows assigned volunteers" do
          visit edit_supervisor_path(supervisor)

          expect(page).to have_text "Assigned Volunteers"
          expect(page).to_not have_button("Include unassigned")
          expect(page).to_not have_text("Currently Assigned To")
          supervisor.volunteers.each do |volunteer|
            expect(page).to have_text volunteer.email
          end
        end

        context "when there are previously unassigned volunteers" do
          let!(:unassigned_volunteer) { create(:supervisor_volunteer, :inactive, supervisor: supervisor).volunteer }

          it "does not show them by default" do
            visit edit_supervisor_path(supervisor)

            expect(page).to_not have_text unassigned_volunteer.email
            expect(page).to have_button("Include unassigned")

            click_on "Include unassigned"

            expect(page).to have_button("Hide unassigned")
            expect(page).to have_text("All Volunteers")
            expect(page).to have_text unassigned_volunteer.email
            expect(page).to have_text "Currently Assigned To"
          end
        end
      end

      context "when there are no currently assigned volunteers" do
        let(:supervisor) { create(:supervisor, casa_org: organization) }

        context "and there are previously unassigned volunteers" do
          let!(:unassigned_volunteer) { create(:supervisor_volunteer, :inactive, supervisor: supervisor).volunteer }

          it "does not show them by default" do
            visit edit_supervisor_path(supervisor)

            expect(page).to have_text "Assigned Volunteers"
            expect(page).to_not have_text unassigned_volunteer.email
            expect(page).to have_button("Include unassigned")

            click_on "Include unassigned"

            expect(page).to have_button("Hide unassigned")
            expect(page).to have_text unassigned_volunteer.email
            expect(page).to have_text "No One"
            expect(page).to have_text "Currently Assigned To"

            click_on "Hide unassigned"

            expect(page).to_not have_text "Currently Assigned To"
            expect(page).to_not have_text "No One"
          end
        end
      end
    end
  end
end
