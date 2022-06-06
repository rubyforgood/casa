# Preview all emails at http://localhost:3000/rails/mailers/volunteer_mailer
# :nocov:
class VolunteerMailerPreview < ActionMailer::Preview
  def account_setup
    user = params.has_key?(:id) ? get_user(params[:id]) : Volunteer.last
    VolunteerMailer.account_setup(user)
  end

  def court_report_reminder
    user = params.has_key?(:id) ? get_user(params[:id]) : Volunteer.last
    VolunteerMailer.court_report_reminder(user, Date.today)
  end

  def case_contacts_reminder
    user = params.has_key?(:id) ? get_user(params[:id]) : Volunteer.last
    user.supervisor = params.has_key?(:id) ? User.find_by(id: params[:id]) : User.first
    VolunteerMailer.case_contacts_reminder(user, true)
  end

  private

  def get_user(user_id)
    user = User.find_by(id: user_id)
    user&.volunteer? ? user : Volunteer.last
  end
end
# :nocov:
