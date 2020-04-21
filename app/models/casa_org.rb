class CasaOrg < ApplicationRecord
  validates :name, presence: true
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
