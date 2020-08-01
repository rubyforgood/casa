# not a database model -- used for display in tables
# volunteer is a user role and is controlled by User model
class Volunteer < User
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
