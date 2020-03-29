class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ALL_ROLES = %w[inactive volunteer supervisor casa_admin].freeze

  enum roles: ALL_ROLES.zip(ALL_ROLES).to_h
end
