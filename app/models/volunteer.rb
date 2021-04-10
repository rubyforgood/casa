# not a database model -- used for display in tables
# volunteer is a user role and is controlled by User model
class Volunteer < User
  NAME_COLUMN = "name"
  EMAIL_COLUMN = "email"
  SUPERVISOR_COLUMN = "supervisor"
  STATUS_COLUMN = "status"
  ASSIGNED_TO_TRANSITION_AGED_YOUTH_COLUMN = "assigned_to_transition_aged_youth"
  CASE_NUMBER_COLUMN = "case_number"
  LAST_CONTACT_MADE_COLUMN = "last_contact_made"
  CONTACT_MADE_IN_PAST_DAYS_NUM = 60
  CONTACT_MADE_IN_PAST_DAYS_COLUMN = "contact_made_in_past_#{CONTACT_MADE_IN_PAST_DAYS_NUM}_days".freeze
  ACTIONS_COLUMN = "actions"
  TABLE_COLUMNS = [
    NAME_COLUMN,
    EMAIL_COLUMN,
    SUPERVISOR_COLUMN,
    STATUS_COLUMN,
    ASSIGNED_TO_TRANSITION_AGED_YOUTH_COLUMN,
    CASE_NUMBER_COLUMN,
    LAST_CONTACT_MADE_COLUMN,
    CONTACT_MADE_IN_PAST_DAYS_COLUMN,
    ACTIONS_COLUMN
  ].freeze
  CONTACT_MADE_IN_DAYS_NUM = 14
  COURT_REPORT_SUBMISSION_REMINDER = 7.days

  scope :with_no_supervisor, lambda { |org|
    joins("left join supervisor_volunteers "\
          "on supervisor_volunteers.volunteer_id = users.id "\
          "and supervisor_volunteers.is_active")
      .active
      .in_organization(org)
      .where(supervisor_volunteers: {id: nil})
  }

  def self.email_court_report_reminder
    active.includes(:case_assignments).where.not(case_assignments: nil).find_each do |volunteer|
      volunteer.case_assignments.active.each do |case_assignment|
        current_case = case_assignment.casa_case
        report_due_date = current_case.court_report_due_date
        if (report_due_date == Date.current + COURT_REPORT_SUBMISSION_REMINDER) && current_case.court_report_not_submitted?
          VolunteerMailer.court_report_reminder(volunteer, report_due_date)
        end
      end
    end
  end

  # Activates this volunteer.
  def activate
    update(active: true)
  end

  # Deactivates this volunteer and all of their case assignments.
  def deactivate
    transaction do
      updated = update(active: false)
      if updated
        case_assignments.update_all(active: false)
      end

      updated
    end
  end

  def case_assignments_with_cases
    case_assignments.includes(:casa_case)
  end

  def has_supervisor?
    supervisor_volunteer.present? && supervisor_volunteer&.is_active?
  end

  def supervised_by?(supervisor)
    self.supervisor == supervisor
  end

  # false if volunteer has any case with no contact in the past 30 days
  def made_contact_with_all_cases_in_days?(num_days = CONTACT_MADE_IN_DAYS_NUM)
    # TODO this should do the same thing as no_contact_for_two_weeks but for a volunteer
    total_active_case_count = actively_assigned_and_active_cases.size
    return true if total_active_case_count.zero?
    current_contact_cases_count = cases_where_contact_made_in_days(num_days).count
    current_contact_cases_count == total_active_case_count
  end

  private

  def cases_where_contact_made_in_days(num_days = CONTACT_MADE_IN_DAYS_NUM)
    actively_assigned_and_active_cases
      .joins(:case_contacts)
      .where(case_contacts: {contact_made: true, occurred_at: num_days.days.ago.to_date..})
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  active                 :boolean          default(TRUE)
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
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
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
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
