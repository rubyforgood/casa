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
    volunteer_no_transition_youth_cases = object.casa_cases.pluck(:transition_aged_youth).all? false

    volunteer_no_transition_youth_cases ? 'No' : 'Yes'
  end
end
