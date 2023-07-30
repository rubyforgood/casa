class LearningHour < ApplicationRecord
  belongs_to :user
  belongs_to :learning_hour_type

  validates :duration_minutes, presence: true
  validates :duration_minutes, numericality: {greater_than: 0}, if: :zero_duration_hours?
  validates :name, presence: {message: "/ Title cannot be blank"}
  validates :occurred_at, presence: true
  validate :occurred_at_not_in_future

  private

  def zero_duration_hours?
    duration_hours == 0
  end

  def occurred_at_not_in_future
    return false if !occurred_at

    if occurred_at > Date.today
      errors.add(:date, "cannot be in the future")
    end
  end
end

# == Schema Information
#
# Table name: learning_hours
#
#  id                    :bigint           not null, primary key
#  duration_hours        :integer          not null
#  duration_minutes      :integer          not null
#  name                  :string           not null
#  occurred_at           :datetime         not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  learning_hour_type_id :bigint
#  user_id               :bigint           not null
#
# Indexes
#
#  index_learning_hours_on_learning_hour_type_id  (learning_hour_type_id)
#  index_learning_hours_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (learning_hour_type_id => learning_hour_types.id)
#  fk_rails_...  (user_id => users.id)
#
