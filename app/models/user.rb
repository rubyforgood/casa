# frozen_string_literal: true

# model for all user roles: volunteer supervisor casa_admin inactive
class User < ApplicationRecord
  has_paper_trail
  devise :database_authenticatable, :invitable, :recoverable, :rememberable, :validatable

  belongs_to :casa_org

  has_many :case_assignments, foreign_key: "volunteer_id"
  has_many :casa_cases, through: :case_assignments
  has_many :case_contacts, foreign_key: "creator_id"

  has_many :supervisor_volunteers, foreign_key: "supervisor_id"
  has_many :volunteers, -> { order(:display_name) }, through: :supervisor_volunteers

  has_one :supervisor_volunteer, foreign_key: "volunteer_id"
  has_one :supervisor, through: :supervisor_volunteer

  scope :volunteers_with_no_supervisor, lambda { |org|
    joins("left join supervisor_volunteers "\
          "on supervisor_volunteers.volunteer_id = users.id "\
          "and supervisor_volunteers.is_active")
      .active
      .in_organization(org)
      .where(supervisor_volunteers: { id: nil })
  }

  scope :active, -> { where(active: true) }

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

  def policy_class
    case type
    when Volunteer
      VolunteerPolicy
    else
      UserPolicy
    end
  end

  # all contacts this user has with this casa case
  def case_contacts_for(casa_case_id)
    found_casa_case = casa_cases.find { |cc| cc.id == casa_case_id }
    found_casa_case.case_contacts.filter { |contact| contact.creator_id == id }
  end

  def recent_contacts_made(days_counter = 60)
    case_contacts.where(contact_made: true, occurred_at: days_counter.days.ago..Date.today).size
  end

  def most_recent_contact
    case_contacts.where(contact_made: true).order(:occurred_at).last
  end

  def volunteers_serving_transistion_aged_youth
    volunteers.includes(:casa_cases)
      .where(casa_cases: {transition_aged_youth: true}).size
  end

  def no_contact_for_two_weeks
    volunteers.includes(:case_contacts)
      .where(case_contacts: {contact_made: true})
      .where.not(case_contacts: {occurred_at: 14.days.ago..Date.today}).size
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
    !active ? :inactive : super
  end

  def serving_transition_aged_youth?
    casa_cases.where(transition_aged_youth: true).any?
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
