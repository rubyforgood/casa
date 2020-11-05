class VolunteerMailer < ApplicationMailer
  default from: "CASA Admin <no-reply@casa-r4g-staging.herokuapp.com>"

  def deactivation(user)
    @user = user
    mail(to: @user.email, subject: "Your account has been deactivated")
  end

  def account_setup(user)
    @user = user
    @token = @user.generate_password_reset_token
    mail(to: @user.email, subject: "Create a password & set up your account")
  end

  def court_report_reminder(user, court_report_due_date)
    @user = user
    @court_report_due_date = court_report_due_date
    mail(to: @user.email, subject: "Your court report is due on: #{court_report_due_date}")
  end
end
