# Preview all emails at http://localhost:3000/rails/mailers/supervisor_mailer
# :nocov:
class SupervisorMailerPreview < ActionMailer::Preview
  def account_setup
    supervisor = if params.has_key?(:id) then Supervisor.find_by(id: params[:id]) else Supervisor.last end
    SupervisorMailer.account_setup(supervisor)
  end

  def weekly_digest
    supervisor = if params.has_key?(:id) then Supervisor.find_by(id: params[:id]) else Supervisor.last end
    SupervisorMailer.weekly_digest(supervisor)
  end
end
# :nocov:
