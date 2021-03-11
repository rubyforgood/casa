# Preview all emails at http://localhost:3000/rails/mailers/supervisor_mailer
# :nocov:
class SupervisorMailerPreview < ActionMailer::Preview
  def weekly_digest
    SupervisorMailer.weekly_digest(Supervisor.first)
  end
end
# :nocov:
