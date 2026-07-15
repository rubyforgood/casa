# Preview all emails at http://localhost:3000/rails/mailers/volunteer_mailer
# :nocov:
require_relative "../debug_preview_mailer"
class VolunteerMailerPreview < ActionMailer::Preview
  def account_setup
    volunteer = params.has_key?(:id) ? Volunteer.find_by(id: params[:id]) : Volunteer.last
    if volunteer.nil?
      DebugPreviewMailer.invalid_user("volunteer")
    else
      VolunteerMailer.account_setup(volunteer)
    end
  end

  def court_report_reminder
    volunteer = params.has_key?(:id) ? Volunteer.find_by(id: params[:id]) : Volunteer.last
    if volunteer.nil?
      DebugPreviewMailer.invalid_user("volunteer")
    else
      VolunteerMailer.court_report_reminder(volunteer, Date.today)
    end
  end

  def case_contacts_reminder
    volunteer = params.has_key?(:id) ? Volunteer.find_by(id: params[:id]) : Volunteer.last
    if volunteer.nil?
      DebugPreviewMailer.invalid_user("volunteer")
    else
      VolunteerMailer.court_report_reminder(volunteer, true)
    end
  end

  def reimbursement_complete_email
    volunteer = params.has_key?(:id) ? Volunteer.find_by(id: params[:id]) : Volunteer.last
    if volunteer.nil?
      DebugPreviewMailer.invalid_user("volunteer")
    else
      case_contact = CaseContact.where(creator: volunteer, want_driving_reimbursement: true).last
      if case_contact.nil?
        DebugPreviewMailer.no_data("case_contact")
      else
        VolunteerMailer.reimbursement_complete_email(volunteer, case_contact)
      end
    end
  end
end
# :nocov:
