# Preview all emails at http://localhost:3000/rails/mailers/volunteer_mailer
# :nocov:
class VolunteerMailerPreview < ActionMailer::Preview
  def account_setup
    VolunteerMailer.account_setup(get_user)
  end

  def court_report_reminder
    VolunteerMailer.court_report_reminder(get_user, Date.today)
  end

  def case_contacts_reminder
    user = get_user
    user.supervisor = get_supervisor(user)
    VolunteerMailer.case_contacts_reminder(user, true)
  end

  def get_user
    User.find_by(id: params[:id]) || User.last
  end

  def get_supervisor(user)
    User.where.not(id: user.id).first
  end
end
# :nocov:
