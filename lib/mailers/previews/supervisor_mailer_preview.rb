# Preview all emails at http://localhost:3000/rails/mailers/supervisor_mailer
# :nocov:
class SupervisorMailerPreview < ActionMailer::Preview
  def account_setup
    SupervisorMailer.account_setup(supervisor)
  end

  def weekly_digest
    SupervisorMailer.weekly_digest(supervisor)
  end

  def supervisor
    Supervisor.find_by(id: params[:id]) || Supervisor.last
  end
end
# :nocov:
