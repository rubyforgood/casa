class Supervisor < User
  devise :invitable, invite_for: 2.weeks

  has_many :supervisor_volunteers, foreign_key: "supervisor_id"
  has_many :active_supervisor_volunteers, -> { where(is_active: true) }, class_name: "SupervisorVolunteer", foreign_key: "supervisor_id"
  has_many :unassigned_supervisor_volunteers, -> { where(is_active: false) }, class_name: "SupervisorVolunteer", foreign_key: "supervisor_id"

  has_many :volunteers, -> { includes(:supervisor_volunteer).order(:display_name) }, through: :active_supervisor_volunteers
  has_many :volunteers_ever_assigned, -> { includes(:supervisor_volunteer).order(:display_name) }, through: :supervisor_volunteers, source: :volunteer

  scope :active, -> { where(active: true) }

  # Activates supervisor.
  def activate
    update(active: true)
  end

  # Deactivates supervisor and unassign all volunteers.
  def deactivate
    transaction do
      updated = update(active: false)
      if updated
        supervisor_volunteers.update_all(is_active: false)
      end

      updated
    end
  end

  def change_to_admin!
    becomes!(CasaAdmin).save
  end

  def pending_volunteers
    Volunteer.where(invited_by_id: id).or(
      Volunteer.where(id: volunteers.pluck(:id))
    ).where(invitation_accepted_at: nil).where.not(invitation_created_at: nil)
  end

  def recently_unassigned_volunteers
    unassigned_supervisor_volunteers.joins(:volunteer).includes(:volunteer)
      .where(updated_at: 1.week.ago..Time.zone.now).map(&:volunteer)
  end
end

# == Schema Information
#
# Table name: users
#
#  id                          :bigint           not null, primary key
#  active                      :boolean          default(TRUE)
#  confirmation_sent_at        :datetime
#  confirmation_token          :string
#  confirmed_at                :datetime
#  current_sign_in_at          :datetime
#  current_sign_in_ip          :string
#  display_name                :string           default(""), not null
#  email                       :string           default(""), not null
#  encrypted_password          :string           default(""), not null
#  invitation_accepted_at      :datetime
#  invitation_created_at       :datetime
#  invitation_limit            :integer
#  invitation_sent_at          :datetime
#  invitation_token            :string
#  invitations_count           :integer          default(0)
#  invited_by_type             :string
#  last_sign_in_at             :datetime
#  last_sign_in_ip             :string
#  old_emails                  :string           default([]), is an Array
#  phone_number                :string           default("")
#  receive_email_notifications :boolean          default(TRUE)
#  receive_reimbursement_email :boolean          default(FALSE)
#  receive_sms_notifications   :boolean          default(FALSE), not null
#  reset_password_sent_at      :datetime
#  reset_password_token        :string
#  sign_in_count               :integer          default(0), not null
#  token                       :string
#  type                        :string
#  unconfirmed_email           :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  casa_org_id                 :bigint           not null
#  invited_by_id               :bigint
#
# Indexes
#
#  index_users_on_casa_org_id                        (casa_org_id)
#  index_users_on_confirmation_token                 (confirmation_token) UNIQUE
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
