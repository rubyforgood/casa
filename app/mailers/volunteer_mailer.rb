class VolunteerMailer < ApplicationMailer
  def deactivation(user)
    @category = __callee__
    @user = user
    @casa_organization = user.casa_org
    @subject = "Your account has been deactivated"

    mail(to: @user.email, subject: @subject)
  end

  def account_setup(user)
    @category = __callee__
    @user = user
    @casa_organization = user.casa_org
    @subject = "Create a password & set up your account"
    @token = @user.generate_password_reset_token

    mail(to: @user.email, subject: @subject)
  end

  def court_report_reminder(user, court_report_due_date)
    @category = __callee__
    @user = user
    @casa_organization = user.casa_org
    @court_report_due_date = court_report_due_date
    @subject = "Your court report is due on: #{court_report_due_date}"

    mail(to: @user.email, subject: @subject)
  end

  def case_contacts_reminder(user)
    @category = __callee__
    @user = user
    @casa_organization = user.casa_org
    @subject = "Reminder to input case contacts"

    mail(to: @user.email, subject: @subject)
  end
end
