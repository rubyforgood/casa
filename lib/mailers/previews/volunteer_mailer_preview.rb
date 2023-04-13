# Preview all emails at http://localhost:3000/rails/mailers/volunteer_mailer
# :nocov:
class VolunteerMailerPreview < ActionMailer::Preview
  def account_setup
    volunteer = params.has_key?(:id) ? Volunteer.find_by(id: params[:id]) : Volunteer.last
    if volunteer.nil?
      ActiveSupport::Notifications.unsubscribe("process.action_mailer")
      ActionMailer::Base.mail(
        from: "no-rply@example.com",
        to: "not_a_volunteer@example.com",
        subject: "No Volunteer has been found",
        body: "This is a debugging message letting you know no volunteer has been found"
      )
    else
      VolunteerMailer.account_setup(volunteer)
    end
  end

  def court_report_reminder
    volunteer = params.has_key?(:id) ? Volunteer.find_by(id: params[:id]) : Volunteer.last
    if volunteer.nil?
      ActiveSupport::Notifications.unsubscribe("process.action_mailer")
      ActionMailer::Base.mail(
        from: "no-rply@example.com",
        to: "not_a_volunteer@example.com",
        subject: "No Volunteer has been found",
        body: "This is a debugging message letting you know no volunteer has been found"
      )
    else
      VolunteerMailer.court_report_reminder(volunteer, Date.today)
    end
  end

  def case_contacts_reminder
    volunteer = params.has_key?(:id) ? Volunteer.find_by(id: params[:id]) : Volunteer.last
    if volunteer.nil?
      ActiveSupport::Notifications.unsubscribe("process.action_mailer")
      ActionMailer::Base.mail(
        from: "no-rply@example.com",
        to: "not_a_volunteer@example.com",
        subject: "No Volunteer has been found",
        body: "This is a debugging message letting you know no volunteer has been found"
      )
    else
      VolunteerMailer.court_report_reminder(volunteer, Date.today)
    end
  end

  #   private

  #   def get_user(user_id)
  #     user = User.find_by(id: user_id)
  #     user&.volunteer? ? user : Volunteer.last
  #   end
end
# :nocov:
