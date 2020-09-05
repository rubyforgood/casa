# Helper methods for new case contact form
module CaseContactsHelper
  def duration_minutes_select(form, case_contact)
    minute_options = build_minute_options

    form.select :duration_minutes,
      options_from_collection_for_select(
        minute_options,
        "value",
        "label",
        case_contact.duration_minutes&.remainder(60)
      ), {prompt: ""},
      class: "custom-select"
  end

  def duration_hours_select(form, case_contact)
    hour_options = build_hour_options

    form.select :duration_hours,
      options_from_collection_for_select(
        hour_options,
        "value",
        "label",
        case_contact.duration_minutes&.div(60)
      ),
      {prompt: ""},
      class: "custom-select"
  end

  def set_hours_form(case_contact)
    case_contact.duration_minutes&.div(60) || 0
  end

  def set_minutes_form(case_contact)
    case_contact.duration_minutes&.remainder(60) || 0
  end

  def set_contact_made_false(case_contact)
    case_contact.persisted? && case_contact.contact_made == false
  end

  def set_contact_made_true(case_contact)
    case_contact.contact_made.present?
  end

  def render_back_link(casa_case)
    return send_home if !current_user || current_user&.volunteer?

    send_to_case(casa_case)
  end

  private

  def build_minute_options
    durations = []

    # Generate 15, 30, 45 minute intervals
    4.times do |i|
      duration = i * 15
      durations.push(OpenStruct.new(value: duration, label: "#{duration} minutes"))
    end

    durations
  end

  def build_hour_options
    durations = []

    # Generate 0 through 23 hour intervals
    24.times do |i|
      duration = i
      durations.push(OpenStruct.new(value: duration, label: "#{duration} #{"hour".pluralize(i)}"))
    end

    durations
  end

  def send_home
    root_path
  end

  def send_to_case(casa_case)
    casa_case_path(casa_case)
  end
end
