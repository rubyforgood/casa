class OtherDutyDecorator < Draper::Decorator
  delegate_all

  NOTES_WORD_LIMIT = 10

  def duration_in_minutes
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

  def truncate_notes
    if object.notes && object.notes.split.size > OtherDutyDecorator::NOTES_WORD_LIMIT
      helpers.content_tag(:p, limited_notes)
    else
      helpers.simple_format(full_notes)
    end
  end

  def limited_notes
    object.notes.truncate_words(NOTES_WORD_LIMIT)
  end

  def full_notes
    object.notes
  end
end
