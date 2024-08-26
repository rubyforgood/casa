desc "Create a notification for supervisors when a volunteer has a birthday coming in the next month, scheduled for the 15th of each month in Heroku Scheduler"
task volunteer_birthday_reminder: :environment do
  VolunteerBirthdayReminderService.new.send_reminders
end
