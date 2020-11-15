desc "Send an email to supervisors each week to share an overview of their volunteers' activities"
task send_supervisor_digest: :environment do
  Supervisor.each do |supervisor|
    SupervisorMailer.weekly_digest(supervisor)
  end
end
