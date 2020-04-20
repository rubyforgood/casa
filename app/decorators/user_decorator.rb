class UserDecorator < Draper::Decorator
  delegate_all

  def status
    return 'Inactive' if object.role == 'inactive'

    'Active'
  end

  # If all of a volunteers cases are not transition youth eligible, then
  # we return "No", otherwise they have at least one transition youth eligible case
  # and we return "Yes"
  def assigned_to_transition_aged_youth?
    volunteer_no_transition_youth_cases = object.casa_cases.pluck(:teen_program_eligible).all? false

    if volunteer_no_transition_youth_cases
      "No"
    else
      "Yes"
    end
  end
end
