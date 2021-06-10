class SupervisorMailer < ApplicationMailer
  def deactivation(supervisor)
    @category = __callee__
    @user = supervisor
    @casa_organization = supervisor.casa_org
    @subject = "Your account has been deactivated"
    
    mail(to: @user.email, subject: @subject)
  end

  def account_setup(supervisor)
    @category = __callee__
    @user = supervisor
    @casa_organization = supervisor.casa_org
    @subject = "Create a password & set up your account"
    @token = @user.generate_password_reset_token

    mail(to: @user.email, subject: @subject)
  end

  def weekly_digest(supervisor)
    @category = __callee__
    @user = supervisor
    @casa_organization = supervisor.casa_org
    @subject = "Weekly summary of volunteers' activities for the week of #{Date.today - 7.days}"

    mail(to: @user.email, subject: @subject)
  end
end
