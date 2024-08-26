desc "Create a notification for volunteers with transition aged youth to utilize the Emancipation Checklist, scheduled once per month in Heroku Scheduler"
task emancipation_checklist_reminder: :environment do
  if Time.now.utc.to_date.day == 1
    EmancipationChecklistReminderService.new.send_reminders
  end
end
