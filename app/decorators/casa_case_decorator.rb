class CasaCaseDecorator < Draper::Decorator
  delegate_all

  def status
    object.active ? "Active" : "Inactive"
  end

  def transition_aged_youth_icon
    object.transition_aged_youth ? "Yes 🐛🦋" : "No"
  end

  def transition_aged_youth_only_icon
    object.transition_aged_youth ? "🐛🦋" : ""
  end

  def court_report_submission
    object.court_report_status.humanize
  end

  def court_report_submitted_date
    object.court_report_submitted_at&.strftime("%B%e, %Y")
  end

  def case_contacts_ordered_by_occurred_at
    object.case_contacts.sort_by(&:occurred_at)
  end

  def court_report_select_option
    [
      "#{object.case_number} - #{object.has_transitioned? ? "transition" : "non-transition"}",
      object.case_number,
      {"data-transitioned": object.has_transitioned?}
    ]
  end

  def inactive_class
    !object.active ? "table-secondary" : ""
  end
end
