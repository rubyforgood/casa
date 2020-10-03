class CasaCaseDecorator < Draper::Decorator
  delegate_all

  def transition_aged_youth_icon
    object.transition_aged_youth ? "Yes 🐛🦋" : "No"
  end

  def transition_aged_youth_only_icon
    object.transition_aged_youth ? "🐛🦋" : ""
  end

  def court_report_submission
    object.court_report_submitted ? "Submitted" : "Not Submitted"
  end

  def case_contacts_ordered_by_occurred_at
    object.case_contacts.sort_by(&:occurred_at)
  end
end
