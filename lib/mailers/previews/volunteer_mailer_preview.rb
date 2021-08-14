# Preview all emails at http://localhost:3000/rails/mailers/volunteer_mailer
# :nocov:
class VolunteerMailerPreview < ActionMailer::Preview
  def deactivation
    user = User.find_by(id: params[:id]) || User.last
    VolunteerMailer.deactivation(user)
  end

  def account_setup
    user = User.find_by(id: params[:id]) || User.last
    VolunteerMailer.account_setup(user)
  end

  def court_report_reminder
    user = User.find_by(id: params[:id]) || User.last
    VolunteerMailer.court_report_reminder(user, Date.today)
  end

  def case_contacts_reminder
    user = User.find_by(id: params[:id]) || User.last
    user.supervisor = User.find_by(id: params[:id]) || User.first
    VolunteerMailer.case_contacts_reminder(user, true)
  end
end
# :nocov:
