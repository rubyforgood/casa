class CaseContactDecorator < Draper::Decorator
  delegate_all

  NOTES_CHARACTER_LIMIT = 100

  def duration_minutes
    minutes = object.duration_minutes

    return "#{minutes} minutes" if minutes <= 60

    formatted_hour_value = minutes / 60
    formatted_minutes_value = minutes.remainder(60)

    if formatted_minutes_value.zero?
      "#{formatted_hour_value} #{"hour".pluralize(formatted_hour_value)}"
    else
      "#{formatted_hour_value} #{"hour".pluralize(formatted_hour_value)} #{formatted_minutes_value} minutes"
    end
  end

  def report_duration_minutes
    object.duration_minutes
  end

  def miles_traveled
    object.miles_driven.zero? ? nil : "#{object.miles_driven} miles driven"
  end

  def reimbursement
    object.want_driving_reimbursement ? "Reimbursement" : nil
  end

  def contact_made
    object.contact_made ? nil : "No Contact Made"
  end

  def report_contact_made
    object.contact_made
  end

  def subheading
    [
      I18n.l(object.occurred_at, format: :full, default: nil),
      duration_minutes,
      contact_made,
      miles_traveled,
      reimbursement
    ].compact.join(" | ")
  end

  def paragraph_notes
    if object.notes && object.notes.length > CaseContactDecorator::NOTES_CHARACTER_LIMIT
      helpers.content_tag(:p, limited_notes)
    else
      helpers.simple_format(full_notes)
    end
  end

  def contact_types
    if object.contact_types.any?
      object.contact_types&.map { |ct| ct.name }&.to_sentence(last_word_connector: ", and ")
    else
      "No contact type specified"
    end
  end

  def report_contact_types
    object.contact_types&.map { |ct| ct.name }&.join("|")
  end

  def medium_icon_classes
    case object.medium_type
    when CaseContact::IN_PERSON
      "lni lni-users"
    when CaseContact::TEXT_EMAIL
      "lni lni-envelope"
    when CaseContact::VIDEO
      "lni lni-camera"
    when CaseContact::VOICE_ONLY
      "lni lni-phone"
    when CaseContact::LETTER
      "lni lni-empty-file"
    else
      "lni lni-question-circle"
    end
  end

  def limited_notes
    object.notes.truncate(NOTES_CHARACTER_LIMIT)
  end

  def full_notes
    object.notes
  end

  def show_contact_type?(contact_type_id)
    object.case_contact_contact_type.map(&:contact_type_id).include?(contact_type_id)
  end

  def additional_expenses_count
    object.additional_expenses.any? ? object.additional_expenses.length : 0
  end
end
