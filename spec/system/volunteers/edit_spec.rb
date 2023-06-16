require "rails_helper"

RSpec.describe "volunteers/edit", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org_id: organization.id) }
  let(:volunteer) { create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id) }

  it "shows invite and login info" do
    sign_in admin
    visit edit_volunteer_path(volunteer)
    expect(page).to have_text "Added to system "
    expect(page).to have_text "Invitation email sent never"
    expect(page).to have_text "Last logged in"
    expect(page).to have_text "Invitation accepted never"
    expect(page).to have_text "Password reset last sent never"
    expect(page).to have_text "Learning Hours This Year 0h 0min"
  end

  describe "updating volunteer personal data" do
    before do
      sign_in admin
      visit edit_volunteer_path(volunteer)
      fill_in "volunteer_display_name", with: "Kamisato Ayato"
    end

    context "with valid data" do
      it "updates successfully" do
        click_on "Submit"
        expect(page).to have_text "Volunteer was successfully updated."
      end
    end

    context "with invalid data" do
      let(:role) { "volunteer" }

      it_should_behave_like "shows error for invalid phone numbers"

      it "shows error message for duplicate email" do
        volunteer.supervisor = build(:supervisor)
        fill_in "volunteer_email", with: admin.email
        fill_in "volunteer_display_name", with: "Mickey Mouse"
        click_on "Submit"
        expect(page).to have_text "already been taken"
      end

      it "shows error message for empty fields" do
        volunteer.supervisor = create(:supervisor)
        fill_in "volunteer_email", with: ""
        fill_in "volunteer_display_name", with: ""
        click_on "Submit"
        expect(page).to have_text "can't be blank"
      end
    end
  end

  describe "updating a volunteer's email" do
    before do
      sign_in admin
      visit edit_volunteer_path(volunteer)
      @old_email = volunteer.email
      fill_in "Email", with: "newemail@example.com"
      click_on "Submit"
      volunteer.reload
    end

    context "with a valid email" do
      it "sends volunteer a confirmation email and does not change the displayed email" do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
        expect(ActionMailer::Base.deliveries.first.body.encoded)
          .to match("You can confirm your account email through the link below:")

        expect(page).to have_text "Volunteer was successfully updated. Confirmation Email Sent."
        expect(page).to have_field("Email", with: @old_email)
        expect(volunteer.unconfirmed_email).to eq("newemail@example.com")
      end

      it "succesfully displays the new email once the user confirms" do
        volunteer.reload
        volunteer.confirm

        visit edit_volunteer_path(volunteer)
        expect(page).to have_field("Email", with: "newemail@example.com")
        expect(page).to_not have_field("Email", with: @old_email)
        expect(volunteer.old_emails).to eq([@old_email])
      end
    end
  end

  it "saves the user as inactive, but only if the admin confirms", js: true do
    sign_in admin
    visit edit_volunteer_path(volunteer)

    dismiss_confirm do
      click_on "Deactivate volunteer"
    end
    expect(page).not_to have_text("Volunteer was deactivated on")

    accept_confirm do
      click_on "Deactivate volunteer"
    end
    expect(page).to have_text("Volunteer was deactivated on")

    expect(volunteer.reload).not_to be_active
  end

  it "allows an admin to reactivate a volunteer" do
    inactive_volunteer = build(:volunteer, casa_org_id: organization.id)
    inactive_volunteer.deactivate

    sign_in admin

    visit edit_volunteer_path(inactive_volunteer)

    click_on "Activate volunteer"

    expect(page).not_to have_text("Volunteer was deactivated on")

    expect(inactive_volunteer.reload).to be_active
  end

  it "allows the admin to unassign a volunteer from a supervisor" do
    supervisor = build(:supervisor, display_name: "Haka Haka", casa_org: organization)
    volunteer = create(:volunteer, display_name: "Bolu Bolu", supervisor: supervisor, casa_org: organization)

    sign_in admin

    visit edit_volunteer_path(volunteer)

    expect(page).to have_content("Current Supervisor: Haka Haka")

    click_on "Unassign from Supervisor"

    expect(page).to have_content("Bolu Bolu was unassigned from Haka Haka")
  end

  it "shows the admin the option to assign an unassigned volunteer to a different active supervisor" do
    volunteer = create(:volunteer, casa_org: organization)
    deactivated_supervisor = create(:supervisor, active: false, casa_org: organization, display_name: "Inactive Supervisor")
    active_supervisor = create(:supervisor, active: true, casa_org: organization, display_name: "Active Supervisor")

    sign_in admin

    visit edit_volunteer_path(volunteer)
    expect(page).not_to have_select("supervisor_volunteer[supervisor_id]", with_options: [deactivated_supervisor.display_name])
    expect(page).to have_select("supervisor_volunteer[supervisor_id]", options: [active_supervisor.display_name])
    expect(page).to have_content("Select a Supervisor")
    expect(page).to have_content("Assign a Supervisor")
  end

  context "when the volunteer is unassigned from all of their cases" do
    let!(:casa_case_1) { create(:casa_case, casa_org: organization, case_number: "CINA1") }
    let!(:casa_case_2) { create(:casa_case, casa_org: organization, case_number: "CINA2") }
    let!(:case_assignment_1) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case_1) }
    let!(:case_assignment_2) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case_2) }

    before do
      case_assignment_1.active = false
      case_assignment_2.active = false
      case_assignment_1.save
      case_assignment_2.save
    end

    it "does not show any active assignment status in the Manage Cases section" do
      sign_in admin
      visit edit_volunteer_path(volunteer)
      within "#manage_cases" do
        expect(page).not_to have_content("Volunteer is Active")
      end
    end

    it "shows the unassigned cases in the Manage Cases section" do
      sign_in admin
      visit edit_volunteer_path(volunteer)

      within "#case_assignment_#{case_assignment_1.id}" do
        expect(page).to have_link("CINA1", href: "/casa_cases/#{casa_case_1.case_number.parameterize}")
      end

      within "#case_assignment_#{case_assignment_2.id}" do
        expect(page).to have_link("CINA2", href: "/casa_cases/#{casa_case_2.case_number.parameterize}")
      end
    end

    it "shows assignment status as 'Volunteer is Unassigned' for each unassigned case" do
      sign_in admin
      visit edit_volunteer_path(volunteer)

      within "#case_assignment_#{case_assignment_1.id}" do
        expect(page).to have_content("Volunteer is Unassigned")
      end

      within "#case_assignment_#{case_assignment_2.id}" do
        expect(page).to have_content("Volunteer is Unassigned")
      end
    end
  end

  context "with a deactivated case" do
    it "displays inactive message" do
      deactivated_casa_case = create(:casa_case, active: false, casa_org: volunteer.casa_org, volunteers: [volunteer])
      sign_in admin

      visit edit_volunteer_path(volunteer)
      expect(page).to have_text "Case was deactivated on: #{I18n.l(deactivated_casa_case.updated_at, format: :standard, default: nil)}"
    end
  end

  context "when volunteer is assigned to multiple cases" do
    let(:casa_org) { build(:casa_org) }
    let!(:supervisor) { create(:casa_admin, casa_org: casa_org) }
    let!(:volunteer) { create(:volunteer, casa_org: casa_org, display_name: "AAA") }
    let!(:casa_case_1) { create(:casa_case, casa_org: casa_org, case_number: "CINA1") }
    let!(:casa_case_2) { create(:casa_case, casa_org: casa_org, case_number: "CINA2") }

    it "supervisor assigns multiple cases to the same volunteer" do
      sign_in supervisor
      visit edit_volunteer_path(volunteer.id)

      select casa_case_1.case_number, from: "Select a Case"
      click_on "Assign Case"
      expect(page).to have_text("Volunteer assigned to case")
      expect(page).to have_text(casa_case_1.case_number)

      select casa_case_2.case_number, from: "Select a Case"
      click_on "Assign Case"
      expect(page).to have_text("Volunteer assigned to case")
      expect(page).to have_text(casa_case_2.case_number)
    end
  end

  context "with previously assigned cases" do
    let(:casa_org) { build(:casa_org) }
    let!(:supervisor) { create(:casa_admin, casa_org: casa_org) }
    let!(:volunteer) { create(:volunteer, casa_org: casa_org, display_name: "AAA") }
    let!(:casa_case_1) { build(:casa_case, casa_org: casa_org, case_number: "CINA1") }
    let!(:casa_case_2) { build(:casa_case, casa_org: casa_org, case_number: "CINA2") }

    it "shows the unassign button for assigned cases and not for unassigned cases" do
      sign_in supervisor

      assignment1 = volunteer.case_assignments.create(casa_case: casa_case_1, active: true)
      assignment2 = volunteer.case_assignments.create(casa_case: casa_case_2, active: false)

      visit edit_volunteer_path(volunteer)

      within("#case_assignment_#{assignment1.id}") do
        expect(page).to have_text(casa_case_1.case_number)
        expect(page).to have_button("Unassign Case")
      end

      within("#case_assignment_#{assignment2.id}") do
        expect(page).to have_text(casa_case_2.case_number)
        expect(page).not_to have_button("Unassign Case")
      end

      select casa_case_2.case_number, from: "Select a Case"
      click_on "Assign Case"

      within("#case_assignment_#{assignment2.id}") do
        expect(page).to have_text(casa_case_2.case_number)
        expect(page).to have_button("Unassign Case")
      end
    end
  end

  describe "inactive case visibility" do
    let!(:active_casa_case) { create(:casa_case, casa_org: organization, case_number: "ACTIVE") }
    let!(:inactive_casa_case) { create(:casa_case, casa_org: organization, active: false, case_number: "INACTIVE") }
    let!(:volunteer) { create(:volunteer, display_name: "Awesome Volunteer", casa_org: organization) }
    let(:supervisor) { build(:casa_admin, casa_org: organization) }

    it "supervisor does not have inactive cases as an option to assign to a volunteer" do
      sign_in supervisor
      visit edit_volunteer_path(volunteer)

      expect(page).to have_content(active_casa_case.case_number)
      expect(page).not_to have_content(inactive_casa_case.case_number)
    end
  end

  describe "resend invite" do
    let(:supervisor) { create(:supervisor, casa_org: organization) }

    it "allows a supervisor resend invitation to a volunteer", js: true do
      sign_in supervisor

      visit edit_volunteer_path(volunteer)

      click_on "Resend Invitation"

      expect(page).to have_content("Invitation sent")

      deliveries = ActionMailer::Base.deliveries
      expect(deliveries.count).to eq(1)
      expect(deliveries.last.subject).to have_text "CASA Console invitation instructions"
    end
  end

  it "allows an administrator resend invitation to a volunteer", js: true do
    sign_in admin

    visit edit_volunteer_path(volunteer)

    click_on "Resend Invitation"

    expect(page).to have_content("Invitation sent")

    deliveries = ActionMailer::Base.deliveries
    expect(deliveries.count).to eq(1)
    expect(deliveries.last.subject).to have_text "CASA Console invitation instructions"
  end

  describe "Send Reactivation (SMS)" do
    pending "waiting on rebase"
    before do
      sign_in admin
    end
    it "allows admin to send a reactivation SMS to a volunteer if the org has twilio enabled", js: true do
      visit edit_volunteer_path(voluntter)
      expect(page).to have_content("Send Reactivation Alert (SMS)")
      expect(page).to have_selector("#twilio_enabled", disabled: false)
    end

    it "is disabled if admin's organization does not have twilio enabled", js: true do
      organization.update(twilio_enabled: false)
      reload
      visit edit_volunteer_path(voluntter)

      expect(page).to have_content("Enable Twilio Send Reactivation Alert (SMS)")
      expect(page).to have_selector("#twilio_disabled", disabled: true)
    end
  end

  describe "send reminder as a supervisor", js: true do
    let(:supervisor) { create(:supervisor, casa_org: organization) }

    before(:each) do
      sign_in supervisor
    end

    it "emails the volunteer" do
      visit edit_volunteer_path(volunteer)

      expect(page).to have_button("Send Reminder")
      expect(page).to have_text("Send CC to Supervisor")
      uncheck "with_cc"
      click_on "Send Reminder"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.cc).to be_empty
    end

    it "emails volunteer and cc's the supervisor" do
      visit edit_volunteer_path(volunteer)

      check "with_cc"
      click_on "Send Reminder"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.cc).to include(volunteer.supervisor.email)
    end

    it "emails the volunteer without a supervisor" do
      volunteer_without_supervisor = create(:volunteer)
      visit edit_volunteer_path(volunteer_without_supervisor)

      check "with_cc"
      click_on "Send Reminder"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.cc).to be_empty
    end
  end

  describe "send reminder as admin" do
    before(:each) do
      sign_in admin
      visit edit_volunteer_path(volunteer)
    end

    it "emails the volunteer" do
      expect(page).to have_button("Send Reminder")
      expect(page).to have_text("Send CC to Supervisor and Admin")

      click_on "Send Reminder"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it "emails the volunteer and cc's their supervisor and admin" do
      check "with_cc"
      click_on "Send Reminder"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.cc).to include(volunteer.supervisor.email)
      expect(ActionMailer::Base.deliveries.first.cc).to include(admin.email)
    end
  end

  describe "impersonate button" do
    let(:volunteer) { create(:volunteer, casa_org: organization, display_name: "John Doe") }

    before do
      sign_in user
      visit edit_volunteer_path(volunteer)
    end

    context "when user is an admin" do
      let(:user) { create(:casa_admin, casa_org: organization) }

      it "shows the impersonate button" do
        expect(page).to have_link("Impersonate")
      end

      it "impersonates the volunteer" do
        click_on "Impersonate"

        within(".sidebar-nav-wrapper") do
          expect(page).to have_text(
            "You (#{user.display_name}) are signed in as John Doe. " \
              "Click here to stop impersonating."
          )
        end
      end
    end

    context "when user is a supervisor" do
      let(:user) { create(:supervisor, casa_org: organization) }

      it "shows the impersonate button" do
        expect(page).to have_link("Impersonate")
      end

      it "impersonates the volunteer" do
        click_on "Impersonate"

        within(".sidebar-nav-wrapper") do
          expect(page).to have_text(
            "You (#{user.display_name}) are signed in as John Doe. " \
              "Click here to stop impersonating."
          )
        end
      end
    end

    context "when user is a volunteer" do
      let(:user) { create(:volunteer, casa_org: organization) }

      it "does not show the impersonate button", :aggregate_failures do
        expect(page).not_to have_link("Impersonate")
        expect(current_path).not_to eq(edit_volunteer_path(volunteer))
      end
    end
  end

  context "logged in as an admin" do
    let!(:note_1) { volunteer.notes.create(creator: admin, content: "Note_1") }
    let!(:note_2) { volunteer.notes.create(creator: admin, content: "Note_2") }
    let!(:note_3) { volunteer.notes.create(creator: admin, content: "Note_3") }

    before do
      sign_in admin
      visit edit_volunteer_path(volunteer)
    end

    it "can save notes about a volunteer" do
      freeze_time do
        current_date = Date.today
        fill_in("note[content]", with: "Great job today.")
        within(".notes") do
          click_on("Save Note")
        end

        expect(current_path).to eq(edit_volunteer_path(volunteer))
        within(".notes") do
          expect(page).to have_text("Great job today.")
          expect(page).to have_text(admin.display_name)
          expect(page).to have_text(I18n.l(current_date.to_date, format: :standard, default: ""))
        end
      end
    end

    it "can delete notes about a volunteer" do
      expect(page).to have_css ".notes .table tbody tr", count: 3

      click_on("Delete", match: :first)

      expect(page).to have_css ".notes .table tbody tr", count: 2
    end
  end

  context "logged in as a supervisor" do
    let!(:note_1) { volunteer.notes.create(creator: admin, content: "Note_1") }
    let!(:note_2) { volunteer.notes.create(creator: admin, content: "Note_2") }
    let!(:note_3) { volunteer.notes.create(creator: admin, content: "Note_3") }

    before do
      volunteer.supervisor = create(:supervisor)
      sign_in volunteer.supervisor
      visit edit_volunteer_path(volunteer)
    end

    it "can save notes about a volunteer" do
      freeze_time do
        current_date = Date.today
        fill_in("note[content]", with: "Great job today.")
        within(".notes") do
          click_on("Save Note")
        end

        expect(current_path).to eq(edit_volunteer_path(volunteer))
        within(".notes") do
          expect(page).to have_text("Great job today.")
          expect(page).to have_text(volunteer.supervisor.display_name)
          expect(page).to have_text(I18n.l(current_date.to_date, format: :standard, default: ""))
        end
      end
    end

    it "can delete notes about a volunteer" do
      expect(page).to have_css ".notes .table tbody tr", count: 3

      click_on("Delete", match: :first)

      expect(page).to have_css ".notes .table tbody tr", count: 2
    end
  end

  context "logged in as volunteer" do
    before do
      sign_in volunteer
      visit edit_volunteer_path(volunteer)
    end

    it "can't see the notes section" do
      expect(page).not_to have_selector(".notes")
      expect(page).to have_content("Sorry, you are not authorized to perform this action.")
    end
  end

  describe "updating volunteer address" do
    before do
      sign_in admin
      visit edit_volunteer_path(volunteer)
    end

    context "with mileage reimbursement turned on" do
      it "shows 'Mailing address' label" do
        expect(page).to have_text "Mailing address"
        expect(page).to have_selector "input[type=text][id=volunteer_address_attributes_content]"
      end

      it "updates successfully" do
        fill_in "volunteer_address_attributes_content", with: "123 Main St"
        click_on "Submit"
        expect(page).to have_text "Volunteer was successfully updated."
        expect(page).to have_selector("input[value='123 Main St']")
      end
    end

    context "with mileage reimbursement turned off" do
      let(:organization) { create(:casa_org, show_driving_reimbursement: false) }
      let(:volunteer) { create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id) }
      it "won't show 'Mailing address' label" do
        expect(page).not_to have_text "Mailing address"
        expect(page).not_to have_selector "input[type=text][id=volunteer_address_attributes_content]"
      end
    end
  end
end
