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
  end

  describe "updating volunteer personal data" do
    before do
      sign_in admin
      visit edit_volunteer_path(volunteer)
    end

    context "with valid data" do
      it "updates successfully" do
        fill_in "volunteer_email", with: "newemail@example.com"
        fill_in "volunteer_display_name", with: "Mickey Mouse"
        click_on "Submit"
        expect(page).to have_text "Volunteer was successfully updated."
      end
    end

    context "with invalid data" do
      it "shows error message for duplicate email" do
        volunteer.supervisor = create(:supervisor)
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
    inactive_volunteer = create(:volunteer, casa_org_id: organization.id)
    inactive_volunteer.deactivate

    sign_in admin

    visit edit_volunteer_path(inactive_volunteer)

    click_on "Activate volunteer"

    expect(page).not_to have_text("Volunteer was deactivated on")

    expect(inactive_volunteer.reload).to be_active
  end

  it "allows the admin to unassign a volunteer from a supervisor" do
    supervisor = create(:supervisor, display_name: "Haka Haka")
    volunteer = create(:volunteer, display_name: "Bolu Bolu", supervisor: supervisor)

    sign_in admin

    visit edit_volunteer_path(volunteer)

    expect(page).to have_content("Current Supervisor: Haka Haka")

    click_on "Unassign from Supervisor"

    expect(page).to have_content("Bolu Bolu was unassigned from Haka Haka")
  end

  it "shows the admin the option to assign an unassigned volunteer to a different supervisor" do
    volunteer = create(:volunteer)

    sign_in admin

    visit edit_volunteer_path(volunteer)

    expect(page).to have_content("Select a Supervisor")
    expect(page).to have_content("Assign a Supervisor")
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
    let(:casa_org) { create(:casa_org) }
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
    let(:casa_org) { create(:casa_org) }
    let!(:supervisor) { create(:casa_admin, casa_org: casa_org) }
    let!(:volunteer) { create(:volunteer, casa_org: casa_org, display_name: "AAA") }
    let!(:casa_case_1) { create(:casa_case, casa_org: casa_org, case_number: "CINA1") }
    let!(:casa_case_2) { create(:casa_case, casa_org: casa_org, case_number: "CINA2") }

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
    let(:supervisor) { create(:casa_admin, casa_org: organization) }

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

  describe "send reminder as a supervisor" do
    let(:supervisor) { create(:supervisor, casa_org: organization) }

    it "allows a supervisor to send case contact reminder to a volunteer" do
      sign_in supervisor

      visit edit_volunteer_path(volunteer)

      expect(page).to have_button("Send reminder")
      expect(page).to have_text(/Send CC to Supervisor$/)

      click_on "Send reminder"

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end

  it "send reminder as an admin" do
    sign_in admin

    visit edit_volunteer_path(volunteer)

    expect(page).to have_button("Send reminder")
    expect(page).to have_text("Send CC to Supervisor and Admin")

    click_on "Send reminder"

    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end
end
