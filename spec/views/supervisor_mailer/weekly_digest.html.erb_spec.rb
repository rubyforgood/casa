require "rails_helper"

RSpec.describe "supervisor_mailer/weekly_digest", type: :view do
  let(:organization) { create(:casa_org) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:inactive_volunteer) { create(:volunteer, :with_casa_cases, casa_org: organization) }
  let(:supervisor_mailer) { SupervisorMailer.new }

  context "when there are successful and unsuccessful contacts" do
    before(:each) do
      supervisor.volunteers << volunteer
      inactive_volunteer.update active: false
      supervisor.volunteers_ever_assigned << inactive_volunteer
      volunteer.casa_cases << casa_case
      create_list :case_contact, 2, creator: volunteer, casa_case: casa_case, contact_made: false, occurred_at: Time.current - 6.days
      @case_contact = create :case_contact, creator: volunteer, casa_case: casa_case, contact_made: true, occurred_at: Time.current - 6.days
      assign :supervisor, supervisor
      sign_in supervisor
      @inactive_messages = InactiveMessagesService.new(supervisor).inactive_messages
      render template: "supervisor_mailer/weekly_digest"
    end

    it { expect(rendered).to have_text("Here's a summary of what happened with your volunteers this last week.") }
    it { expect(rendered).to have_link(volunteer.display_name) }
    it { expect(rendered).to have_link(casa_case.case_number) }
    it { expect(rendered).not_to have_text(inactive_volunteer.display_name) }
    it { expect(rendered).to have_text("Number of unsuccessful case contacts made this week: 2") }
    it { expect(rendered).to have_text("Number of successful case contacts made this week: 1") }
    it { expect(rendered).to have_text("- Date: #{I18n.l(@case_contact.occurred_at, format: :full, default: nil)}") }
    it { expect(rendered).to have_text("- Type: #{@case_contact.decorate.contact_types}") }
    it { expect(rendered).to have_text("- Duration: #{@case_contact.duration_minutes}") }
    it { expect(rendered).to have_text("- Contact Made: #{@case_contact.contact_made}") }
    it { expect(rendered).to have_text("- Medium Type: #{@case_contact.medium_type}") }
    it { expect(rendered).to have_text("- Notes: #{@case_contact.notes}") }
  end

  context "when there are no volunteers" do
    before(:each) do
      sign_in supervisor
      assign :supervisor, supervisor
      @inactive_messages = InactiveMessagesService.new(supervisor).inactive_messages
      render template: "supervisor_mailer/weekly_digest"
    end

    it { expect(rendered).to have_text("You have no volunteers with assigned cases at the moment. When you do, you will see their status here.") }
  end

  context "when there are volunteers but no contacts" do
    before(:each) do
      supervisor.volunteers << volunteer
      inactive_volunteer.update active: false
      supervisor.volunteers_ever_assigned << inactive_volunteer
      volunteer.casa_cases << casa_case
      sign_in supervisor
      assign :supervisor, supervisor
      @inactive_messages = InactiveMessagesService.new(supervisor).inactive_messages
      render template: "supervisor_mailer/weekly_digest"
    end

    it { expect(rendered).to have_text("No contact attempts were logged for this week.") }
  end

  context "when a volunteer has been reassigned to a new supervisor" do
    before(:each) do
      supervisor.volunteers << volunteer
      volunteer.casa_cases << casa_case

      # reassign volunteer
      volunteer.supervisor_volunteer.update(is_active: false)
      other_supervisor.volunteers << volunteer
      volunteer.supervisor_volunteer.update(is_active: true)

      sign_in supervisor
      assign :supervisor, supervisor
      render template: "supervisor_mailer/weekly_digest"
    end

    let(:other_supervisor) { create(:supervisor) }

    it { expect(rendered).to include("The following volunteers have been unassigned from you", volunteer.display_name) }
  end

  context "when a volunteer has been unassigned" do
    before(:each) do
      supervisor.volunteers << volunteer
      sign_in supervisor
      volunteer.supervisor_volunteer.update(is_active: false)

      new_supervisor.volunteers << volunteer
      volunteer.supervisor_volunteer.update(is_active: true)
      assign :supervisor, supervisor
      @inactive_messages = []

      render template: "supervisor_mailer/weekly_digest"
    end

    let(:new_supervisor) { create(:supervisor) }

    it { expect(rendered).to have_text("The following volunteers have been unassigned from you") }
    it { expect(rendered).to have_text("- #{volunteer.display_name}") }
  end

  context "when a volunteer unassigned and has not been assigned to a new supervisor" do
    before(:each) do
      supervisor.volunteers << volunteer
      sign_in supervisor
      assign :supervisor, supervisor
      volunteer.supervisor_volunteer.update(is_active: false)
      @inactive_messages = []
      render template: "supervisor_mailer/weekly_digest"
    end

    it { expect(rendered).to have_text("The following volunteers have been unassigned from you") }
    it { expect(rendered).to have_text("- #{volunteer.display_name}") }
    it { expect(rendered).to have_text("(not assigned to a new supervisor)") }
  end

  context "when a volunteer has not recently signed in, within 30 days" do
    let(:volunteer) { create(:volunteer, casa_org: organization, last_sign_in_at: 39.days.ago) }
    before(:each) do
      supervisor.volunteers << volunteer
      sign_in supervisor
      assign :supervisor, supervisor
      render template: "supervisor_mailer/weekly_digest"
    end

    it { expect(rendered).to have_text("The following volunteers have not recently signed in, within 30 days") }
    it { expect(rendered).to have_text("- #{volunteer.display_name}") }
  end
end
