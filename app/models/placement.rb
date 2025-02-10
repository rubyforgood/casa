class Placement < ApplicationRecord
  belongs_to :casa_case
  belongs_to :placement_type
  belongs_to :creator, class_name: "User"
  has_one :casa_org, through: :casa_case

  validates :placement_started_at, comparison: {
    greater_than_or_equal_to: "1989-01-01".to_date,
    message: "cannot be prior to 1/1/1989.",
    allow_nil: true
  }
  validates :placement_started_at, comparison: {
    less_than_or_equal_to: -> { 1.year.from_now },
    message: "must not be more than one year in the future.",
    allow_nil: true
  }
end

# == Schema Information
#
# Table name: placements
#
#  id                   :bigint           not null, primary key
#  placement_started_at :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  casa_case_id         :bigint           not null
#  creator_id           :bigint           not null
#  placement_type_id    :bigint           not null
#
# Indexes
#
#  index_placements_on_casa_case_id       (casa_case_id)
#  index_placements_on_creator_id         (creator_id)
#  index_placements_on_placement_type_id  (placement_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (placement_type_id => placement_types.id)
#
