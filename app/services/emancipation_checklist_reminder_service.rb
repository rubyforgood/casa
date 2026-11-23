class EmancipationChecklistReminderService
  attr_reader :cases

  def initialize(casa_org = nil)
    @casa_org = casa_org
    scope = CaseAssignment
      .active
      .includes(:casa_case, :volunteer)
      .where(casa_cases: {
        birth_month_year_youth: ..CasaCase::TRANSITION_AGE.years.ago
      })
    @cases = @casa_org ? scope.where(casa_cases: {casa_org_id: @casa_org.id}) : scope
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
      unless first_of_month?(org) || ENV["FORCE"] == "true"
        Rails.logger.info { "Emancipation Checklist Reminder skipped for CasaOrg #{org.id}. Today is not the 1st of the month." }
        return
      end

      start_of_month = org.time_zone_now.beginning_of_month.utc

      org_cases = CaseAssignment
        .active
        .includes(:casa_case, :volunteer)
        .where(casa_cases: {
          casa_org_id: org.id,
          birth_month_year_youth: ..CasaCase::TRANSITION_AGE.years.ago
        })

      org_cases.find_each do |assignment|
        volunteer = assignment.volunteer
        next unless volunteer

        already_notified = volunteer.notifications
          .includes(:event)
          .where(type: "EmancipationChecklistReminderNotifier::Notification")
          .where("created_at >= ?", start_of_month)
          .any? { |n| n.event&.params&.[](:casa_case)&.id == assignment.casa_case_id || n.event&.params&.[](:casa_case) == assignment.casa_case }
        next if already_notified

        ::EmancipationChecklistReminderNotifier
          .with(casa_case: assignment.casa_case)
          .deliver(volunteer)
      end
    end
  rescue => e
    Rails.logger.error("Failed sending emancipation checklist reminder for CasaOrg #{org.id}: #{e.message}")
  end

  def first_of_month?(org)
    if Time.now.utc == Time.now.utc.midnight
      Time.now.utc.to_date.day == 1
    else
      org.today.day == 1
    end
  end
end
