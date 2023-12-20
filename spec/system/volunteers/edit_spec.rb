require "rails_helper"

RSpec.describe "volunteers/edit", type: :system do
  describe "updating volunteer personal data" do
    context "with valid data" do
      it "updates successfully" do
        organization = create(:casa_org)
        admin = create(:casa_admin, casa_org_id: organization.id)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)

        sign_in admin
        visit edit_volunteer_path(volunteer)

        fill_in "volunteer_display_name", with: "Kamisato Ayato"
        fill_in "volunteer_phone_number", with: "+14163248967"
        fill_in "volunteer_date_of_birth", with: "1988/07/01"
        click_on "Submit"

        expect(page).to have_text "Volunteer was successfully updated."
      end
    end

    context "with invalid data" do
      context "shows error for invalid phone number" do
        it "shows error message for phone number < 12 digits" do
          organization = create(:casa_org)
          admin = create(:casa_admin, casa_org_id: organization.id)
          volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)

          sign_in admin
          visit edit_volunteer_path(volunteer)

          fill_in "volunteer_phone_number", with: "+141632489"
          click_on "Submit"
          expect(page).to have_text "Phone number must be 10 digits or 12 digits including country code (+1)"
        end

        it "shows error message for phone number > 12 digits" do
          organization = create(:casa_org)
          admin = create(:casa_admin, casa_org_id: organization.id)
          volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)

          sign_in admin
          visit edit_volunteer_path(volunteer)

          fill_in "volunteer_phone_number", with: "+141632180923"
          click_on "Submit"

          expect(page).to have_text "Phone number must be 10 digits or 12 digits including country code (+1)"
        end

        it "shows error message for bad phone number" do
          organization = create(:casa_org)
          admin = create(:casa_admin, casa_org_id: organization.id)
          volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)

          sign_in admin
          visit edit_volunteer_path(volunteer)

          fill_in "volunteer_phone_number", with: "+141632u809o"
          click_on "Submit"

          expect(page).to have_text "Phone number must be 10 digits or 12 digits including country code (+1)"
        end

        it "shows error message for phone number without country code" do
          organization = create(:casa_org)
          admin = create(:casa_admin, casa_org_id: organization.id)
          volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)

          sign_in admin
          visit edit_volunteer_path(volunteer)

          fill_in "volunteer_phone_number", with: "+24163218092"
          click_on "Submit"

          expect(page).to have_text "Phone number must be 10 digits or 12 digits including country code (+1)"
        end

        it "shows error message for invalid date of birth" do
          organization = create(:casa_org)
          admin = create(:casa_admin, casa_org_id: organization.id)
          volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)

          sign_in admin
          visit edit_volunteer_path(volunteer)

          fill_in "volunteer_date_of_birth", with: 5.days.from_now.strftime("%Y/%m/%d")
          click_on "Submit"

          expect(page).to have_text "Date of birth must be in the past."
        end
      end

      it "shows error message for duplicate email" do
        organization = create(:casa_org)
        admin = create(:casa_admin, casa_org_id: organization.id)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
        volunteer.supervisor = build(:supervisor)

        sign_in admin
        visit edit_volunteer_path(volunteer)

        fill_in "volunteer_display_name", with: "Kamisato Ayato"
        fill_in "volunteer_email", with: admin.email
        fill_in "volunteer_display_name", with: "Mickey Mouse"
        click_on "Submit"

        expect(page).to have_text "already been taken"
      end

      it "shows error message for empty fields" do
        organization = create(:casa_org)
        admin = create(:casa_admin, casa_org_id: organization.id)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
        volunteer.supervisor = create(:supervisor)

        sign_in admin
        visit edit_volunteer_path(volunteer)

        fill_in "volunteer_email", with: ""
        fill_in "volunteer_display_name", with: ""
        click_on "Submit"

        expect(page).to have_text "can't be blank"
      end
    end
  end

  describe "updating a volunteer's email" do
    context "with a valid email" do
      it "sends volunteer a confirmation email and does not change the displayed email" do
        organization = create(:casa_org)
        admin = create(:casa_admin, casa_org: organization)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
        old_email = volunteer.email

        sign_in admin
        visit edit_volunteer_path(volunteer)

        fill_in "Email", with: "newemail@example.com"
        click_on "Submit"
        volunteer.reload

        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first).to be_a(Mail::Message)
        expect(ActionMailer::Base.deliveries.first.body.encoded)
          .to match("You can confirm your account email through the link below:")

        expect(page).to have_text "Volunteer was successfully updated. Confirmation Email Sent."
        expect(page).to have_field("Email", with: old_email)
        expect(volunteer.unconfirmed_email).to eq("newemail@example.com")
      end

      it "succesfully displays the new email once the user confirms" do
        organization = create(:casa_org)
        admin = create(:casa_admin, casa_org: organization)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
        old_email = volunteer.email

        sign_in admin
        visit edit_volunteer_path(volunteer)

        fill_in "Email", with: "newemail@example.com"
        click_on "Submit"
        volunteer.reload
        volunteer.confirm

        visit edit_volunteer_path(volunteer)

        expect(page).to have_field("Email", with: "newemail@example.com")
        expect(page).to_not have_field("Email", with: old_email)
        expect(volunteer.old_emails).to eq([old_email])
      end
    end
  end

  it "saves the user as inactive, but only if the admin confirms", js: true do
    organization = create(:casa_org)
    admin = create(:casa_admin, casa_org: organization)
    volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)

    sign_in admin
    visit edit_volunteer_path(volunteer)

    dismiss_confirm do
      scroll_to(".actions")
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
    organization = create(:casa_org)
    admin = create(:casa_admin, casa_org: organization)
    inactive_volunteer = build(:volunteer, casa_org: organization)
    inactive_volunteer.deactivate

    sign_in admin

    visit edit_volunteer_path(inactive_volunteer)

    click_on "Activate volunteer"

    expect(page).not_to have_text("Volunteer was deactivated on")

    expect(inactive_volunteer.reload).to be_active
  end

  it "allows the admin to unassign a volunteer from a supervisor" do
    organization = create(:casa_org)
    supervisor = build(:supervisor, display_name: "Haka Haka", casa_org: organization)
    volunteer = create(:volunteer, display_name: "Bolu Bolu", supervisor: supervisor, casa_org: organization)
    admin = create(:casa_admin, casa_org: organization)

    sign_in admin
    visit edit_volunteer_path(volunteer)

    expect(page).to have_content("Current Supervisor: Haka Haka")

    click_on "Unassign from Supervisor"

    expect(page).to have_content("Bolu Bolu was unassigned from Haka Haka")
  end

  it "shows the admin the option to assign an unassigned volunteer to a different active supervisor" do
    organization = create(:casa_org)
    volunteer = create(:volunteer, casa_org: organization)
    deactivated_supervisor = create(:supervisor, active: false, casa_org: organization, display_name: "Inactive Supervisor")
    active_supervisor = create(:supervisor, active: true, casa_org: organization, display_name: "Active Supervisor")
    admin = create(:casa_admin, casa_org: organization)

    sign_in admin
    visit edit_volunteer_path(volunteer)

    expect(page).not_to have_select("supervisor_volunteer[supervisor_id]", with_options: [deactivated_supervisor.display_name])
    expect(page).to have_select("supervisor_volunteer[supervisor_id]", options: [active_supervisor.display_name])
    expect(page).to have_content("Select a Supervisor")
    expect(page).to have_content("Assign a Supervisor")
  end

  context "when the volunteer is unassigned from all of their cases" do
    it "does not show any active assignment status in the Manage Cases section" do
      organization = create(:casa_org)
      admin = create(:casa_admin, casa_org_id: organization.id)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
      casa_case_1 = create(:casa_case, casa_org: organization, case_number: "CINA1")
      casa_case_2 = create(:casa_case, casa_org: organization, case_number: "CINA2")
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case_1)
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case_2)
      casa_case_1.update!(active: false)
      casa_case_2.update!(active: false)

      sign_in admin
      visit edit_volunteer_path(volunteer)

      within "#manage_cases" do
        expect(page).not_to have_content("Volunteer is Active")
      end
    end

    it "shows the unassigned cases in the Manage Cases section" do
      organization = create(:casa_org)
      admin = create(:casa_admin, casa_org_id: organization.id)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
      casa_case_1 = create(:casa_case, casa_org: organization, case_number: "CINA1")
      casa_case_2 = create(:casa_case, casa_org: organization, case_number: "CINA2")
      case_assignment_1 = create(:case_assignment, volunteer: volunteer, casa_case: casa_case_1)
      case_assignment_2 = create(:case_assignment, volunteer: volunteer, casa_case: casa_case_2)
      casa_case_1.update!(active: false)
      casa_case_2.update!(active: false)

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
      organization = create(:casa_org)
      admin = create(:casa_admin, casa_org_id: organization.id)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
      casa_case_1 = create(:casa_case, casa_org: organization, case_number: "CINA1")
      casa_case_2 = create(:casa_case, casa_org: organization, case_number: "CINA2")
      case_assignment_1 = create(:case_assignment, volunteer: volunteer, casa_case: casa_case_1)
      case_assignment_2 = create(:case_assignment, volunteer: volunteer, casa_case: casa_case_2)

      case_assignment_1.active = false
      case_assignment_2.active = false
      case_assignment_1.save
      case_assignment_2.save

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
      organization = create(:casa_org)
      admin = create(:casa_admin, casa_org_id: organization.id)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
      deactivated_casa_case = create(:casa_case, active: false, casa_org: volunteer.casa_org, volunteers: [volunteer])

      sign_in admin
      visit edit_volunteer_path(volunteer)

      expect(page).to have_text "Case was deactivated on: #{I18n.l(deactivated_casa_case.updated_at, format: :standard, default: nil)}"
    end
  end

  context "when volunteer is assigned to multiple cases" do
    it "supervisor assigns multiple cases to the same volunteer" do
      casa_org = build(:casa_org)
      supervisor = create(:casa_admin, casa_org: casa_org)
      volunteer = create(:volunteer, casa_org: casa_org, display_name: "AAA")
      casa_case_1 = create(:casa_case, casa_org: casa_org, case_number: "CINA1")
      casa_case_2 = create(:casa_case, casa_org: casa_org, case_number: "CINA2")

      sign_in supervisor
      visit edit_volunteer_path(volunteer)

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
    it "shows the unassign button for assigned cases and not for unassigned cases" do
      casa_org = build(:casa_org)
      supervisor = create(:casa_admin, casa_org: casa_org)
      volunteer = create(:volunteer, casa_org: casa_org, display_name: "AAA")
      casa_case_1 = build(:casa_case, casa_org: casa_org, case_number: "CINA1")
      casa_case_2 = build(:casa_case, casa_org: casa_org, case_number: "CINA2")
      assignment1 = volunteer.case_assignments.create(casa_case: casa_case_1, active: true)
      assignment2 = volunteer.case_assignments.create(casa_case: casa_case_2, active: false)

      sign_in supervisor
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
    it "supervisor does not have inactive cases as an option to assign to a volunteer" do
      organization = build(:casa_org)
      active_casa_case = create(:casa_case, casa_org: organization, case_number: "ACTIVE")
      inactive_casa_case = create(:casa_case, casa_org: organization, active: false, case_number: "INACTIVE")
      volunteer = create(:volunteer, display_name: "Awesome Volunteer", casa_org: organization)
      supervisor = build(:casa_admin, casa_org: organization)

      sign_in supervisor
      visit edit_volunteer_path(volunteer)

      expect(page).to have_content(active_casa_case.case_number)
      expect(page).not_to have_content(inactive_casa_case.case_number)
    end
  end

  describe "resend invite" do
    it "allows a supervisor resend invitation to a volunteer" do
      organization = create(:casa_org)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
      supervisor = create(:supervisor, casa_org: organization)

      sign_in supervisor
      visit edit_volunteer_path(volunteer)

      click_on "Resend Invitation"

      expect(page).to have_content("Invitation sent")

      deliveries = ActionMailer::Base.deliveries
      expect(deliveries.count).to eq(1)
      expect(deliveries.last.subject).to have_text "CASA Console invitation instructions"
    end
  end

  it "allows an administrator resend invitation to a volunteer" do
    organization = create(:casa_org)
    volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
    admin = create(:casa_admin, casa_org: organization)

    sign_in admin
    visit edit_volunteer_path(volunteer)

    click_on "Resend Invitation"

    expect(page).to have_content("Invitation sent")

    deliveries = ActionMailer::Base.deliveries
    expect(deliveries.count).to eq(1)
    expect(deliveries.last.subject).to have_text "CASA Console invitation instructions"
  end

  describe "Send Reactivation (SMS)" do
    it "allows admin to send a reactivation SMS to a volunteer if their org has twilio enabled" do
      organization = create(:casa_org, twilio_enabled: true)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
      admin = create(:casa_admin, casa_org: organization)

      sign_in admin
      visit edit_volunteer_path(volunteer)

      expect(page).to have_content("Send Reactivation Alert (SMS)")
      expect(page).not_to have_content("Enable Twilio")
      expect(page).to have_selector("#twilio_enabled")
    end

    context " admin's organization does not have twilio enabled" do
      it "displays a disabed (SMS) button with appropriate message" do
        org_twilio = create(:casa_org, twilio_enabled: false)
        admin_twilio = create(:casa_admin, casa_org: org_twilio)
        volunteer_twilio = create(:volunteer, casa_org: org_twilio)

        sign_in admin_twilio
        visit edit_volunteer_path(volunteer_twilio)

        expect(page).to have_content("Enable Twilio To Send Reactivation Alert (SMS)")
        expect(page).to have_selector("#twilio_disabled")
      end
    end
  end

  describe "send reminder as a supervisor" do
    it "emails the volunteer" do
      organization = create(:casa_org)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
      supervisor = create(:supervisor, casa_org: organization)

      sign_in supervisor
      visit edit_volunteer_path(volunteer)

      expect(page).to have_button("Send Reminder")
      expect(page).to have_text("Send CC to Supervisor")
      uncheck "with_cc"
      click_on "Send Reminder"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.cc).to be_empty
    end

    it "emails volunteer and cc's the supervisor" do
      organization = create(:casa_org)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
      supervisor = create(:supervisor, casa_org: organization)

      sign_in supervisor
      visit edit_volunteer_path(volunteer)

      check "with_cc"
      click_on "Send Reminder"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.cc).to include(volunteer.supervisor.email)
    end

    it "emails the volunteer without a supervisor" do
      organization = create(:casa_org)
      volunteer_without_supervisor = create(:volunteer)
      supervisor = create(:supervisor, casa_org: organization)

      sign_in supervisor
      visit edit_volunteer_path(volunteer_without_supervisor)

      check "with_cc"
      click_on "Send Reminder"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.cc).to be_empty
    end
  end

  describe "send reminder as admin" do
    it "emails the volunteer" do
      organization = create(:casa_org)
      admin = create(:casa_admin, casa_org_id: organization.id)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)

      sign_in admin
      visit edit_volunteer_path(volunteer)

      expect(page).to have_button("Send Reminder")
      expect(page).to have_text("Send CC to Supervisor and Admin")

      click_on "Send Reminder"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it "emails the volunteer and cc's their supervisor and admin" do
      organization = create(:casa_org)
      admin = create(:casa_admin, casa_org_id: organization.id)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)

      sign_in admin
      visit edit_volunteer_path(volunteer)
      check "with_cc"
      click_on "Send Reminder"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.cc).to include(volunteer.supervisor.email)
      expect(ActionMailer::Base.deliveries.first.cc).to include(admin.email)
    end
  end

  describe "impersonate button" do
    context "when user is an admin" do
      it "impersonates the volunteer" do
        organization = create(:casa_org)
        admin = create(:casa_admin, casa_org: organization)
        volunteer = create(:volunteer, casa_org: organization, display_name: "John Doe")
        sign_in admin
        visit edit_volunteer_path(volunteer)

        click_on "Impersonate"

        within(".sidebar-nav-wrapper") do
          expect(page).to have_text(
            "You (#{admin.display_name}) are signed in as John Doe. " \
              "Click here to stop impersonating."
          )
        end
      end
    end

    context "when user is a supervisor" do
      it "impersonates the volunteer" do
        organization = create(:casa_org)
        supervisor = create(:supervisor, casa_org: organization)
        volunteer = create(:volunteer, casa_org: organization, display_name: "John Doe")
        sign_in supervisor
        visit edit_volunteer_path(volunteer)

        click_on "Impersonate"

        within(".sidebar-nav-wrapper") do
          expect(page).to have_text(
            "You (#{supervisor.display_name}) are signed in as John Doe. " \
              "Click here to stop impersonating."
          )
        end
      end
    end

    context "when user is a volunteer" do
      it "does not show the impersonate button", :aggregate_failures do
        organization = create(:casa_org)
        volunteer = create(:volunteer, casa_org: organization)
        user = create(:volunteer, casa_org: organization)

        sign_in user
        visit edit_volunteer_path(volunteer)

        expect(page).not_to have_link("Impersonate")
        expect(current_path).not_to eq(edit_volunteer_path(volunteer))
      end
    end
  end

  context "logged in as an admin" do
    it "can save notes about a volunteer" do
      organization = create(:casa_org)
      admin = create(:casa_admin, casa_org_id: organization.id)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
      volunteer.notes.create(creator: admin, content: "Note_1")
      volunteer.notes.create(creator: admin, content: "Note_2")
      volunteer.notes.create(creator: admin, content: "Note_3")

      sign_in admin
      visit edit_volunteer_path(volunteer)

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
      organization = create(:casa_org)
      admin = create(:casa_admin, casa_org_id: organization.id)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
      volunteer.notes.create(creator: admin, content: "Note_1")
      volunteer.notes.create(creator: admin, content: "Note_2")
      volunteer.notes.create(creator: admin, content: "Note_3")

      sign_in admin
      visit edit_volunteer_path(volunteer)

      expect(page).to have_css ".notes .table tbody tr", count: 3

      click_on("Delete", match: :first)

      expect(page).to have_css ".notes .table tbody tr", count: 2
    end
  end

  context "logged in as a supervisor" do
    it "can save notes about a volunteer" do
      organization = create(:casa_org)
      admin = create(:casa_admin, casa_org_id: organization.id)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
      supervisor = volunteer.supervisor
      volunteer.notes.create(creator: admin, content: "Note_1")
      volunteer.notes.create(creator: admin, content: "Note_2")
      volunteer.notes.create(creator: admin, content: "Note_3")

      sign_in supervisor
      visit edit_volunteer_path(volunteer)

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
      organization = create(:casa_org)
      admin = create(:casa_admin, casa_org_id: organization.id)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)
      supervisor = volunteer.supervisor
      volunteer.notes.create(creator: admin, content: "Note_1")
      volunteer.notes.create(creator: admin, content: "Note_2")
      volunteer.notes.create(creator: admin, content: "Note_3")

      sign_in supervisor
      visit edit_volunteer_path(volunteer)

      expect(page).to have_css ".notes .table tbody tr", count: 3

      click_on("Delete", match: :first)

      expect(page).to have_css ".notes .table tbody tr", count: 2
    end
  end

  context "logged in as volunteer" do
    it "can't see the notes section" do
      organization = create(:casa_org)
      volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
      sign_in volunteer
      visit edit_volunteer_path(volunteer)

      expect(page).not_to have_selector(".notes")
      expect(page).to have_content("Sorry, you are not authorized to perform this action.")
    end
  end

  describe "updating volunteer address" do
    context "with mileage reimbursement turned on" do
      it "shows 'Mailing address' label" do
        organization = create(:casa_org)
        admin = create(:casa_admin, casa_org_id: organization.id)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)

        sign_in admin
        visit edit_volunteer_path(volunteer)

        expect(page).to have_text "Mailing address"
        expect(page).to have_selector "input[type=text][id=volunteer_address_attributes_content]"
      end

      it "updates successfully" do
        organization = create(:casa_org)
        admin = create(:casa_admin, casa_org_id: organization.id)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id)

        sign_in admin
        visit edit_volunteer_path(volunteer)

        fill_in "volunteer_address_attributes_content", with: "123 Main St"
        click_on "Submit"
        expect(page).to have_text "Volunteer was successfully updated."
        expect(page).to have_selector("input[value='123 Main St']")
      end
    end
  end
end
