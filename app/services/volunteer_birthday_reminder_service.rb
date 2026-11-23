class VolunteerBirthdayReminderService
  def initialize(casa_org = nil)
    @casa_org = casa_org
  end

  def send_reminders
    if @casa_org
      send_for_org(@casa_org)
    else
      CasaOrg.find_each do |org|
        send_for_org(org)
      end
    end
  end

  private

  def send_for_org(org)
    org.with_time_zone do
      unless fifteenth_of_month?(org) || ENV["FORCE"] == "true"
        Rails.logger.info { "Volunteer Birthday Reminder skipped for CasaOrg #{org.id}. Today is not the 15th of the month." }
        return
      end

      start_of_month = org.time_zone_now.beginning_of_month.utc

      org.volunteers.active.with_supervisor.birthday_next_month.each do |volunteer|
        supervisor = volunteer.supervisor
        next unless supervisor

        already_notified = supervisor.notifications
          .includes(:event)
          .where(type: "VolunteerBirthdayNotifier::Notification")
          .where("created_at >= ?", start_of_month)
          .any? { |n| n.event&.params&.[](:volunteer)&.id == volunteer.id || n.event&.params&.[](:volunteer) == volunteer }
        next if already_notified

        VolunteerBirthdayNotifier
          .with(volunteer: volunteer)
          .deliver(supervisor)
      end
    end
  rescue => e
    Rails.logger.error("Failed sending volunteer birthday reminder for CasaOrg #{org.id}: #{e.message}")
  end

  def fifteenth_of_month?(org)
    if Time.now.utc == Time.now.utc.midnight
      Time.now.utc.to_date.day == 15
    else
      org.today.day == 15
    end
  end
end
