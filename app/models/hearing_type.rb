class HearingType < ApplicationRecord
  has_paper_trail

  belongs_to :casa_org

  validates :name, presence: true, uniqueness: {scope: %i[casa_org]}

  default_scope { order(name: :asc) }
  scope :for_organization, ->(org) { where(casa_org: org) }
  scope :active, -> { where(active: true) }
end

# == Schema Information
#
# Table name: hearing_types
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE), not null
#  name        :string           not null
#  casa_org_id :bigint           not null
#
# Indexes
#
#  index_hearing_types_on_casa_org_id  (casa_org_id)
#
