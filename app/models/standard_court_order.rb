class StandardCourtOrder < ApplicationRecord
  belongs_to :casa_org

  validates :value, uniqueness: {scope: :casa_org_id, case_sensitive: false}, presence: true
end

# == Schema Information
#
# Table name: standard_court_orders
#
#  id          :bigint           not null, primary key
#  value       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  casa_org_id :bigint           not null
#
# Indexes
#
#  index_standard_court_orders_on_casa_org_id  (casa_org_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
