# Preview all emails at http://localhost:3000/rails/mailers/supervisor_mailer
# :nocov:
require_relative "../debug_preview_mailer"

class SupervisorMailerPreview < ActionMailer::Preview
  def account_setup
    supervisor = params.has_key?(:id) ? Supervisor.find_by(id: params[:id]) : Supervisor.last
    if supervisor.nil?
      DebugPreviewMailer.invalid_user("supervisor")
    else
      SupervisorMailer.account_setup(supervisor)
    end
  end

  def weekly_digest_no_volunteers
    supervisor = Supervisor.new(
      display_name: "Jane Smith",
      casa_org: CasaOrg.new(name: "CASA of Awesome County"),
      volunteers: []
    )
    SupervisorMailer.weekly_digest(supervisor)
  end

  def weekly_digest_more_data
    supervisor = Supervisor.new(
      display_name: "Jane Smith",
      casa_org: CasaOrg.new(name: "CASA of Awesome County"),
      volunteers: [Volunteer.new(display_name: "Anne Volunteerson"), Volunteer.new(display_name: "Betty McVolunteer")]
    )
    SupervisorMailer.weekly_digest(supervisor)
  end

  def weekly_digest
    supervisor = params.has_key?(:id) ? Supervisor.find_by(id: params[:id]) : Supervisor.last
    if supervisor.nil?
      DebugPreviewMailer.invalid_user("supervisor")
    else
      SupervisorMailer.weekly_digest(supervisor)
    end
  end

  def reimbursement_request_reminder
    volunteer = params.has_key?(:volunteer_id) ? Volunteer.find_by(id: params[:volunteer_id]) : Volunteer.last
    supervisor = params.has_key?(:supervisor_id) ? Supervisor.find_by(id: params[:supervisor_id]) : Supervisor.last
    supervisor.receive_reimbursement_email = true
    SupervisorMailer.reimbursement_request_reminder(volunteer, supervisor)
  end
end

# :nocov:
