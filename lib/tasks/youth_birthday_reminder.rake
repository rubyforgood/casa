desc "Create a notification for volunteers when a youth has a birthday coming in the next month, scheduled for the 15th of each month in Heroku Scheduler"
task youth_birthday_reminder: :environment do
  CasaCase.birthday_next_month.find_each do |casa_case|
    casa_case.case_assignments.active.find_each do |case_assignment|
      YouthBirthdayNotifier
        .with(casa_case: casa_case)
        .deliver(Volunteer.find_by(id: case_assignment.volunteer_id))
    end
  end
end
