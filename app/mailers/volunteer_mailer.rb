class VolunteerMailer < ApplicationMailer
  default from: "CASA Admin <no-reply@casa-r4g-staging.herokuapp.com>"

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def deactivation(user)
    @user = user
    mail(to: @user.email, subject: "Your CASA volunteer account has been deactivated")
  end
end
