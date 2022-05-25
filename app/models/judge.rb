class Judge < ApplicationRecord
  belongs_to :casa_org

  validates :name, presence: true, uniqueness: {scope: %i[casa_org]}
  default_scope { order(name: :asc) }
  scope :for_organization, ->(org) { where(casa_org: org).order(:name) }
  scope :active, -> { where(active: true) }
end

# == Schema Information
#
# Table name: judges
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE)
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  casa_org_id :bigint           not null
#
# Indexes
#
#  index_judges_on_casa_org_id  (casa_org_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
