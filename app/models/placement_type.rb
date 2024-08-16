class PlacementType < ApplicationRecord
  belongs_to :casa_org

  validates :name, presence: true
  scope :for_organization, ->(org) { where(casa_org: org).order(:name) }
end

# == Schema Information
#
# Table name: placement_types
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  casa_org_id :bigint           not null
#
# Indexes
#
#  index_placement_types_on_casa_org_id  (casa_org_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
