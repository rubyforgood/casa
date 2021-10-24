# frozen_string_literal: true

# model for all user roles: volunteer supervisor casa_admin inactive
class User < ApplicationRecord
  include Roles
  include ByOrganizationScope

  has_paper_trail
  devise :database_authenticatable, :invitable, :recoverable, :validatable, :timeoutable, :trackable

  validates :email, presence: true
  validates :display_name, presence: true

  belongs_to :casa_org

  has_many :case_assignments, foreign_key: "volunteer_id", dependent: :destroy # TODO destroy is wrong
  has_many :casa_cases, -> { where(case_assignments: {active: true}) }, through: :case_assignments

  has_many :case_contacts, foreign_key: "creator_id"

  has_many :followups, foreign_key: "creator_id"

  has_many :notifications, as: :recipient
  has_many :sent_emails, dependent: :destroy

  has_one :supervisor_volunteer, -> {
    where(is_active: true)
  }, foreign_key: "volunteer_id", dependent: :destroy
  has_one :supervisor, through: :supervisor_volunteer
  has_one :preference_set, dependent: :destroy

  scope :active, -> { where(active: true) }

  scope :inactive, -> { where(active: false) }

  scope :in_organization, lambda { |org|
    where(casa_org_id: org.id)
  }

  def casa_admin?
    is_a?(CasaAdmin)
  end

  def supervisor?
    is_a?(Supervisor)
  end

  def volunteer?
    is_a?(Volunteer)
  end

  def actively_assigned_and_active_cases
    casa_cases.active.merge(CaseAssignment.active)
  end

  def active_volunteers
    volunteers.active.size
  end

  # all contacts this user has with this casa case
  def case_contacts_for(casa_case_id)
    found_casa_case = actively_assigned_and_active_cases.find { |cc| cc.id == casa_case_id }

    if found_casa_case.nil?
      raise ActiveRecord::RecordNotFound.new "Could not find case with id: #{casa_case_id} belonging to this user"
    end

    found_casa_case.case_contacts.filter { |contact| contact.creator_id == id }
  end

  def recent_contacts_made(days_counter = 60)
    case_contacts.where(contact_made: true, occurred_at: days_counter.days.ago..Date.today).size
  end

  def most_recent_contact
    case_contacts.where(contact_made: true).order(:occurred_at).last
  end

  # Wrong? Linda/Shen/Joshua - unassigned / inactive volunteers
  def volunteers_serving_transition_aged_youth
    volunteers.includes(
      case_assignments: :casa_case
    ).where(
      case_assignments: {active: true}, casa_cases: {active: true, transition_aged_youth: true}
    ).size
  end

  def no_attempt_for_two_weeks
    # Get ACTIVE volunteers that have ACTIVE supervisor assignments with at least one ACTIVE case
    # 1st condition: Volunteer has not created a contact AT ALL within the past 14 days

    volunteers
      .includes(:case_assignments)
      .joins("LEFT JOIN case_contacts cc on cc.creator_id = users.id AND cc.occurred_at > (CURRENT_DATE - INTERVAL '14 days')")
      .group("users.id, supervisor_volunteers_users.id, case_assignments.id")
      .where(active: true)
      .where(supervisor_volunteers: {is_active: true})
      .where(case_assignments: {active: true})
      .length
  end

  def past_names
    # get past_names from paper_trail gem, version_limit is 10 so no performance concerns
    versions.map { |version| version&.reify&.display_name }
  end

  # Generate a Devise reset_token, used for the account_setup mailer. This happens automatically
  # when a user clicks "Reset My Password", so do not use this method in that flow.
  def generate_password_reset_token
    raw_token, hashed_token = Devise.token_generator.generate(self.class, :reset_password_token)

    self.reset_password_token = hashed_token
    self.reset_password_sent_at = Time.now.utc
    save(validate: false)

    raw_token
  end

  # Called by Devise during initial authentication and on each request to
  # validate the user is active. For our purposes, the user is active if they
  # are not inactive
  def active_for_authentication?
    super && active
  end

  # Called by Devise to generate an error message when a user is not active.
  def inactive_message
    if !active
      admin_self_deactivated? ? :admin_self_deactivated : :inactive
    else
      super
    end
  end

  def serving_transition_aged_youth?
    actively_assigned_and_active_cases.where(transition_aged_youth: true).any?
  end

  def admin_self_deactivated?
    return false if !casa_admin? || active
    id.to_s == last_deactivated_by
  end

  def last_deactivated_by
    versions.where(event: "update").reverse_each do |version|
      return version.whodunnit if version.reify.active
    end
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
#  display_name           :string           default(""), not null
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
