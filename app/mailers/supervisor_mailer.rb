class SupervisorMailer < ApplicationMailer
  def deactivation(supervisor)
    @supervisor = supervisor
    @casa_organization = supervisor.casa_org
    mail(to: @supervisor.email, subject: "Your account has been deactivated")
  end

  def account_setup(supervisor)
    @supervisor = supervisor
    @casa_organization = supervisor.casa_org
    @token = @supervisor.generate_password_reset_token
    mail(to: @supervisor.email, subject: "Create a password and set up your account")
  end

  def weekly_digest(supervisor)
    @supervisor = supervisor
    @casa_organization = supervisor.casa_org
    mail(to: @supervisor.email, subject: "Weekly summary of volunteers' activities for the week of #{Date.today - 7.days}")
  end
end
