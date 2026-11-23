desc "Create a notification for volunteers when a youth has a birthday coming in the next month; run daily in Heroku Scheduler, only acts on the 15th"
task youth_birthday_reminder: :environment do
  fifteenth_of_month = ->(org) {
    if Time.now.utc == Time.now.utc.midnight
      Time.now.utc.to_date.day == 15
    else
      org.today.day == 15
    end
  }

  CasaOrg.find_each do |org|
    org.with_time_zone do
      next unless fifteenth_of_month.call(org) || ENV["FORCE"] == "true"

      start_of_month = org.time_zone_now.beginning_of_month.utc

      org.casa_cases.birthday_next_month.find_each do |casa_case|
        casa_case.case_assignments.active.find_each do |case_assignment|
          volunteer = Volunteer.find_by(id: case_assignment.volunteer_id)
          next unless volunteer

          already_notified = volunteer.notifications
            .includes(:event)
            .where(type: "YouthBirthdayNotifier::Notification")
            .where("created_at >= ?", start_of_month)
            .any? { |n| n.event&.params&.[](:casa_case)&.id == casa_case.id || n.event&.params&.[](:casa_case) == casa_case }
          next if already_notified

          YouthBirthdayNotifier
            .with(casa_case: casa_case)
            .deliver(volunteer)
        end
      end
    end
  rescue => e
    Rails.logger.error("Failed running youth birthday reminder for CasaOrg #{org.id}: #{e.message}")
  end
end
