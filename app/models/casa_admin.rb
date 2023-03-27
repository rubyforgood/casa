class CasaAdmin < User
  devise :invitable, invite_for: 2.weeks

  default_scope { order(email: :asc) }

  def activate
    update(active: true)
  end

  def deactivate
    update(active: false)
  end

  def change_to_supervisor!
    becomes!(Supervisor).save
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
#  email_confirmation          :string
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
#  receive_sms_notifications   :boolean          default(FALSE), not null
#  reset_password_sent_at      :datetime
#  reset_password_token        :string
#  sign_in_count               :integer          default(0), not null
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
