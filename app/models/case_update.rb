class CaseUpdate < ApplicationRecord # rubocop:todo Style/Documentation
  has_paper_trail
  belongs_to :user
  belongs_to :casa_case
end

# == Schema Information
#
# Table name: case_updates
#
#  id               :bigint           not null, primary key
#  duration_minutes :integer          not null
#  occurred_at      :datetime         not null
#  other_type_text  :string
#  update_type      :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  casa_case_id     :bigint           not null
#  creator_id       :bigint           not null
#
# Indexes
#
#  index_case_updates_on_casa_case_id  (casa_case_id)
#  index_case_updates_on_creator_id    (creator_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#  fk_rails_...  (creator_id => users.id)
#
