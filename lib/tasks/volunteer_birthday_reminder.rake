desc "Create a notification for supervisors when a volunteer has a birthday coming in the next month, scheduled for the 15th of each month in Heroku Scheduler"
task volunteer_birthday_reminder: :environment do
  # Check if the current day of the month is the 15th
  if Time.now.utc.to_date.day == 15
    Volunteer.active.with_supervisor.birthday_next_month.each do |volunteer|
      VolunteerBirthdayNotification
        .with(volunteer: volunteer)
        .deliver(volunteer.supervisor)
    end
  else
    puts "Volunteer Birthday Reminder Rake task skipped. Today is not the 15th of the month."
  end
end
