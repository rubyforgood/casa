class CaseAssignment < ApplicationRecord
  has_paper_trail
  validates :casa_case_id, uniqueness: { scope: :volunteer_id } # only 1 row allowed per case-volunteer pair
end

# == Schema Information
#
# Table name: case_assignments
#
#  id           :bigint           not null, primary key
#  is_active    :boolean          default(TRUE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  casa_case_id :bigint           not null
#  volunteer_id :bigint           not null
#
# Indexes
#
#  index_case_assignments_on_casa_case_id  (casa_case_id)
#  index_case_assignments_on_volunteer_id  (volunteer_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#  fk_rails_...  (volunteer_id => users.id)
#
