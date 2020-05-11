class CaseContactDecorator < Draper::Decorator
  delegate_all

  # Returns the contact duration in one of the following formats
  # - `N` minutes
  # - `N` hours `M` minutes
  # - `N` hours
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

  def contact_made
    object.contact_made ? "Yes" : "No"
  end

  def contact_types
    object.contact_types
      &.map { |ct| ct.humanize.titleize }
      &.to_sentence(last_word_connector: ", and ") || ""
  end

  def medium_type
    object.medium_type.blank? ? "Unknown" : object.medium_type.titleize
  end
end
