desc "Create a notification for volunteers when a youth has a birthday coming in the next month; run daily in Heroku Scheduler, only acts on the 15th"
task youth_birthday_reminder: :environment do
  next unless Date.current.day == 15 || ENV["FORCE"] == "true"

  CasaCase.birthday_next_month.find_each do |casa_case|
    casa_case.case_assignments.active.find_each do |case_assignment|
      YouthBirthdayNotifier
        .with(casa_case: casa_case)
        .deliver(Volunteer.find_by(id: case_assignment.volunteer_id))
    end
  end
end
