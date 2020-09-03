class CasaOrg < ApplicationRecord
  validates :name, presence: true

  has_many :users
  has_many :casa_cases

  def supervisors
    users.where(type: "Supervisor")
  end

  def volunteers
    users.where(type: "Volunteer")
  end
end

# == Schema Information
#
# Table name: casa_orgs
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
