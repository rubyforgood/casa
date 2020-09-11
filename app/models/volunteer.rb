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

  # Activates this volunteer.
  def activate
    update(active: true)
  end

  # Deactivates this volunteer and all of their case assignments.
  def deactivate
    transaction do
      updated = update(active: false)
      if updated
        case_assignments.update_all(is_active: false)
      end

      updated
    end
  end

  def case_assignments_with_cases
    case_assignments.includes(:casa_case)
  end

  def has_supervisor?
    supervisor_volunteer.present? && supervisor_volunteer.is_active?
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  active                 :boolean          default(TRUE)
#  display_name           :string           default("")
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  invited_by_type        :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  type                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  casa_org_id            :bigint           not null
#  invited_by_id          :bigint
#
# Indexes
#
#  index_users_on_casa_org_id                        (casa_org_id)
#  index_users_on_email                              (email) UNIQUE
#  index_users_on_invitation_token                   (invitation_token) UNIQUE
#  index_users_on_invitations_count                  (invitations_count)
#  index_users_on_invited_by_id                      (invited_by_id)
#  index_users_on_invited_by_type_and_invited_by_id  (invited_by_type,invited_by_id)
#  index_users_on_reset_password_token               (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
