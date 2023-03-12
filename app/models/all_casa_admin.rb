class AllCasaAdmin < ApplicationRecord
  include Roles

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :invitable, :recoverable, :validatable, :timeoutable, invite_for: 1.weeks
end

# == Schema Information
#
# Table name: all_casa_admins
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invited_by_type        :string
#  phone_number           :string           default("")
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :integer
#
# Indexes
#
#  index_all_casa_admins_on_email                 (email) UNIQUE
#  index_all_casa_admins_on_invitation_token      (invitation_token) UNIQUE
#  index_all_casa_admins_on_reset_password_token  (reset_password_token) UNIQUE
#
