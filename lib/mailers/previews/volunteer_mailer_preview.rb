# Preview all emails at http://localhost:3000/rails/mailers/volunteer_mailer
# :nocov:
class VolunteerMailerPreview < ActionMailer::Preview
  def deactivation
    VolunteerMailer.deactivation(User.last)
  end

  def account_setup
    VolunteerMailer.account_setup(User.last)
  end
end
# :nocov:
