class VolunteerBirthdayReminderService
  def send_reminders
    if Time.now.utc.to_date.day == 15
      Volunteer.active.with_supervisor.birthday_next_month.each do |volunteer|
        VolunteerBirthdayNotifier
          .with(volunteer:)
          .deliver(volunteer.supervisor)
      end
    else
      puts "Volunteer Birthday Reminder Rake task skipped. Today is not the 15th of the month."
    end
  end
end
