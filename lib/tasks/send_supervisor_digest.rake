desc "Send an email to supervisors each week to share an overview of their volunteers' activities"
require_relative "supervisor_weekly_digest"
task send_supervisor_digest: :environment do
  SupervisorWeeklyDigest.new.send!
end
