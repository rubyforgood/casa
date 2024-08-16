class PlacementType < ApplicationRecord
  belongs_to :casa_org

  VALID_NAMES = [
    "Reunification",
    "Custody/Guardianship by a relative",
    "Custody/Guardianship by a non-relative",
    "Adoption by relative",
    "Adoption by a non-relative",
    "APPLA"
  ].freeze

  validates :name, presence: true, inclusion: {in: VALID_NAMES}
  scope :for_organization, ->(org) { where(casa_org: org).order(:name) }

  def self.valid_names
    VALID_NAMES
  end
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
