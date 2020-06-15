# model for all user roles: volunteer supervisor casa_admin inactive
class User < ApplicationRecord
  has_paper_trail
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  belongs_to :casa_org

  has_many :case_assignments, foreign_key: "volunteer_id"
  has_many :casa_cases, through: :case_assignments
  has_many :case_contacts, foreign_key: "creator_id"

  has_many :supervisor_volunteers, foreign_key: "supervisor_id"
  has_many :volunteers, through: :supervisor_volunteers

  has_one :supervisor_volunteer, foreign_key: "volunteer_id"
  has_one :supervisor, through: :supervisor_volunteer

  ALL_ROLES = %w[volunteer supervisor casa_admin inactive].freeze
  enum role: ALL_ROLES.zip(ALL_ROLES).to_h

  # all contacts this user has with this casa case
  def case_contacts_for(casa_case_id)
    found_casa_case = casa_cases.find { |cc| cc.id == casa_case_id }
    found_casa_case.case_contacts.filter { |contact| contact.creator_id == id }
  end

  def recent_contacts_made(days_counter = 60)
    case_contacts.where(contact_made: true, occurred_at: days_counter.days.ago..Date.today).count
  end

  def most_recent_contact
    case_contacts.where(contact_made: true).order(:occurred_at).first
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
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  display_name           :string           default("")
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string           default("volunteer"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  casa_org_id            :bigint           not null
#
# Indexes
#
#  index_users_on_casa_org_id           (casa_org_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
