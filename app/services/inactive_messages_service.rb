class InactiveMessagesService
  attr_reader :inactive_messages

  def initialize(supervisor)
    @inactive_messages = calculate_inactive_messages(supervisor)
  end

  private

  def calculate_inactive_messages(supervisor)
    supervisor.volunteers.map do |volunteer|
      inactive_cases = CaseAssignment.inactive_this_week(volunteer.id)
      inactive_cases.map do |case_assignment|
        inactive_case_number = case_assignment.casa_case.case_number
        "#{volunteer.display_name} Case #{inactive_case_number} marked inactive this week."
      end
    end.flatten
  end
end
