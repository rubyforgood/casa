class EmancipationChecklistReminderService
  attr_reader :cases

  def initialize
    @cases = CaseAssignment
      .active
      .includes(:casa_case, :volunteer)
      .where(casa_cases: {
        birth_month_year_youth: ..CasaCase::TRANSITION_AGE.years.ago
      })
  end

  def send_reminders
    if Time.now.utc.to_date.day == 1
      cases.each do |assignment|
        ::EmancipationChecklistReminderNotifier
          .with(casa_case: assignment.casa_case)
          .deliver(assignment.volunteer)
      end
    end
  end
end
