class User < ApplicationRecord # rubocop:todo Style/Documentation
  has_paper_trail
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[inactive volunteer supervisor casa_admin].freeze

  enum roles: ROLES.zip(ROLES).to_h
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
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
