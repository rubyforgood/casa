# Preview all emails at http://localhost:3000/rails/mailers/volunteer_mailer
class VolunteerMailerPreview < ActionMailer::Preview
  def deactivation
    VolunteerMailer.deactivation(User.last)
  end
end
