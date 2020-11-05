class CaseContactDecorator < Draper::Decorator
  delegate_all

  # Returns the contact duration in one of the following formats
  # - `N` minutes
  # - `N` hours `M` minutes
  # - `N` hours

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

  def notes
    object.notes.to_s.truncate(NOTES_WORD_LIMIT)
  end
end
