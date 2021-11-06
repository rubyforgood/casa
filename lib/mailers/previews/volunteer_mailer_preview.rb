# Preview all emails at http://localhost:3000/rails/mailers/volunteer_mailer
# :nocov:
class VolunteerMailerPreview < ActionMailer::Preview
  def account_setup
    user = if params.has_key?(:id) then User.find_by(id: params[:id]) else User.last end
    VolunteerMailer.account_setup(user)
  end

  def court_report_reminder
    user = if params.has_key?(:id) then User.find_by(id: params[:id]) else User.last end
    VolunteerMailer.court_report_reminder(user, Date.today)
  end

  def case_contacts_reminder
    user = if params.has_key?(:id) then User.find_by(id: params[:id]) else User.last end
    user.supervisor = if params.has_key?(:id) then User.find_by(id: params[:id]) else User.first end
    VolunteerMailer.case_contacts_reminder(user, true)
  end
end
# :nocov:
