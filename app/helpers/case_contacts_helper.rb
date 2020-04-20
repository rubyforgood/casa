# Helper methods for new case contact form
module CaseContactsHelper
  def duration_minutes_select(form, case_contact)
    durations = []

    # Generate 15, 30, 45 minute intervals
    4.times do |i|
      duration = i * 15
      durations.push(OpenStruct.new(value: duration, label: "#{duration} minutes"))
    end

    form.select :duration_minutes, options_from_collection_for_select(durations, 'value', 'label', case_contact.duration_minutes&.remainder(60)), {}, class: 'custom-select'
  end

  def duration_hours_select(form, case_contact)
    durations = []

    # Generate 0 through 23 hour intervals
    24.times do |i|
      duration = i
      durations.push(OpenStruct.new(value: duration, label: "#{duration} #{'hour'.pluralize(i)}"))
    end

    form.select :duration_hours, options_from_collection_for_select(durations, 'value', 'label', case_contact.duration_minutes&.div(60)), {}, class: 'custom-select'
  end
end
