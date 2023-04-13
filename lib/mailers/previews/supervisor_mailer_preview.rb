# Preview all emails at http://localhost:3000/rails/mailers/supervisor_mailer
# :nocov:
class SupervisorMailerPreview < ActionMailer::Preview
  def account_setup
    supervisor = params.has_key?(:id) ? Supervisor.find_by(id: params[:id]) : Supervisor.last
    if supervisor.nil?
      ActiveSupport::Notifications.unsubscribe("process.action_mailer")
      ActionMailer::Base.mail(
        from: "no-rply@example.com",
        to: "missing_supervisor@example.com",
        subject: "No Supervisor has been found",
        body: "This is a debugging message letting you know no supervisor has been found"
      )
    else
      SupervisorMailer.account_setup(supervisor)
    end
  end

  def weekly_digest
    supervisor = params.has_key?(:id) ? Supervisor.find_by(id: params[:id]) : Supervisor.last
    if supervisor.nil?
      ActiveSupport::Notifications.unsubscribe("process.action_mailer")
      ActionMailer::Base.mail(
        from: "no-rply@example.com",
        to: "missing_supervisor@example.com",
        subject: "No Supervisor has been found",
        body: "This is a debugging message letting you know no supervisor has been found"
      )
    else
      SupervisorMailer.account_setup(supervisor)
    end
  end
end
# :nocov:
