desc "Create a notification for volunteers with transition aged youth to utilize the Emancipation Checklist, scheduled once per month in Heroku Scheduler"
task emancipation_checklist_reminder: :environment do
  EmancipationChecklistReminderService.new.send_reminders
end
