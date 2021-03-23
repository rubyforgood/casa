class SupervisorMailer < ApplicationMailer
  def weekly_digest(supervisor)
    @supervisor = supervisor
    @casa_organization = supervisor.casa_org
    mail(to: @supervisor.email, subject: "Weekly summary of volunteers' activities for the week of #{Date.today - 7.days}")
  end
end
