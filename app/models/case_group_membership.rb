class CaseGroupMembership < ApplicationRecord
  belongs_to :case_group
  belongs_to :casa_case
  has_one :casa_org, through: :case_group
end

# == Schema Information
#
# Table name: case_group_memberships
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  casa_case_id  :bigint           not null
#  case_group_id :bigint           not null
#
# Indexes
#
#  index_case_group_memberships_on_casa_case_id   (casa_case_id)
#  index_case_group_memberships_on_case_group_id  (case_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#  fk_rails_...  (case_group_id => case_groups.id)
#
