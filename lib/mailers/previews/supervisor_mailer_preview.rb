# Preview all emails at http://localhost:3000/rails/mailers/supervisor_mailer
# :nocov:
require_relative "../debug_preview_mailer"

class SupervisorMailerPreview < ActionMailer::Preview
  def account_setup
    supervisor = params.has_key?(:id) ? Supervisor.find_by(id: params[:id]) : Supervisor.last
    if supervisor.nil?
      DebugPreviewMailer.invalid_user("supervisor")
    else
      SupervisorMailer.account_setup(supervisor)
    end
  end

  def weekly_digest
    supervisor = params.has_key?(:id) ? Supervisor.find_by(id: params[:id]) : Supervisor.last
    if supervisor.nil?
      DebugPreviewMailer.invalid_user("supervisor")
    else
      SupervisorMailer.account_setup(supervisor)
    end
  end
end
# :nocov:
