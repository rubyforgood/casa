class OtherDuty < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  delegate :type, to: :creator, prefix: true

  validates :notes, presence: true
  validates :occurred_at, comparison: {
    less_than_or_equal_to: -> { 1.year.from_now },
    message: "is not valid. Occured on date must be within one year from today."
  }
  validates :occurred_at, comparison: {
    greater_than_or_equal_to: "1989-01-01".to_date,
    message: "is not valid. Occured on date cannot be prior to 1/1/1989."
  }
end

# == Schema Information
#
# Table name: other_duties
#
#  id               :bigint           not null, primary key
#  creator_type     :string
#  duration_minutes :bigint
#  notes            :text
#  occurred_at      :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  creator_id       :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#
