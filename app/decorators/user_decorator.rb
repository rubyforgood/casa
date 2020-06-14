class UserDecorator < Draper::Decorator
  delegate_all

  def status
    return "Inactive" if object.role == "inactive"

    "Active"
  end

  def name
    return object.email if object.display_name.blank?

    object.display_name
  end

  # If all of a volunteers cases are not transition youth eligible, then
  # we return "No", otherwise they have at least one transition youth eligible case
  # and we return "Yes"
  def assigned_to_transition_aged_youth?
    volunteer_no_transition_youth_cases = object.casa_cases.pluck(:transition_aged_youth).all? false

    volunteer_no_transition_youth_cases ? "No" : "Yes"
  end

  def last_contact_made
    if object.most_recent_contact.nil?
      "None ❌"
    else
      object.most_recent_contact.occurred_at.strftime("%B %-e, %Y")
    end
  end
end
