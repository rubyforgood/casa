# Preview all emails at http://localhost:3000/rails/mailers/volunteer_mailer
# :nocov:
class VolunteerMailerPreview < ActionMailer::Preview
  def deactivation
    VolunteerMailer.deactivation(User.last)
  end

  def account_setup
    VolunteerMailer.account_setup(User.last)
  end

  def court_report_reminder
    VolunteerMailer.court_report_reminder(User.last, Date.today)
  end
end
# :nocov:
