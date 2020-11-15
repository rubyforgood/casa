class SupervisorMailer < ApplicationMailer
  default from: "CASA Admin <no-reply@casa-r4g-staging.herokuapp.com>"

  def weekly_digest(supervisor)
    @supervisor = supervisor
    mail(to: @supervisor.email, subject: "Weekly summary of volunteer's activities for the weeek of #{Date.today - 7.days}")
  end
end
