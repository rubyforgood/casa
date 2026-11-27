desc "Prune login activities older than retention window (default 13 months), scheduled daily in Heroku Scheduler"
task prune_login_activities: :environment do
  months = ENV.fetch("LOGIN_ACTIVITY_RETENTION_MONTHS", PruneLoginActivitiesService::DEFAULT_RETENTION_MONTHS)
  deleted = PruneLoginActivitiesService.new(months: months).perform

  puts "Pruned #{deleted} login #{"activity".pluralize(deleted)} older than #{months} months."
end
