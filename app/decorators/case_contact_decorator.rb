class CaseContactDecorator < Draper::Decorator
  delegate_all

  NOTES_WORD_LIMIT = 100

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
    object.miles_driven.zero? ? "" : object.miles_driven
  end

  def reimbursement
    object.want_driving_reimbursement ? "Yes 🟢" : "No"
  end

  def contact_made
    object.contact_made ? "Yes ✅" : "No ❌"
  end

  def report_contact_made
    object.contact_made
  end

  def contact_types
    object.contact_types
      &.map { |ct| ct.name }
      &.to_sentence(last_word_connector: ", and ") || ""
  end

  def report_contact_types
    object.contact_types&.map { |ct| ct.name }&.join("|")
  end

  def medium_type
    object.medium_type.blank? ? "Unknown" : object.medium_type.titleize
  end

  def medium_type_icon
    case object.medium_type
    when CaseContact::IN_PERSON
      "👥 #{object.medium_type}"
    when CaseContact::TEXT_EMAIL
      "🔤 #{object.medium_type}"
    when CaseContact::VIDEO
      "▶ #{object.medium_type}️"
    when CaseContact::VOICE_ONLY
      "📞 #{object.medium_type}"
    when CaseContact::LETTER
      "✉️ #{object.medium_type}️"
    else
      object.medium_type
    end
  end

  def limited_notes
    object.notes.truncate(NOTES_WORD_LIMIT)
  end

  def full_notes
    object.notes
  end

  def show_contact_type?(contact_type_id)
    object.case_contact_contact_type.map(&:contact_type_id).include?(contact_type_id)
  end
end
