class Volunteer
  TABLE_COLUMNS = %w[
    name
    email
    supervisor
    status
    assigned_to_transition_aged_youth
    case_number
    last_contact_made
    contact_made_in_past_60_days
    actions
  ].freeze
end
