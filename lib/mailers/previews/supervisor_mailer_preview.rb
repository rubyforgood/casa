# Preview all emails at http://localhost:3000/rails/mailers/supervisor_mailer
# :nocov:
class SupervisorMailerPreview < ActionMailer::Preview
  def account_setup
    supervisor = Supervisor.find_by(id: params[:id]) || Supervisor.last
    SupervisorMailer.account_setup(supervisor)
  end

  def weekly_digest
    supervisor = Supervisor.find_by(id: params[:id]) || Supervisor.last
    SupervisorMailer.weekly_digest(supervisor)
  end
end
# :nocov:
