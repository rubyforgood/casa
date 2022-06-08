class LearningHour < ApplicationRecord
  belongs_to :user

  enum learning_type: {
    book: 1,
    movie: 2,
    webinar: 3,
    conference: 4,
    other: 5
  }

  validates :learning_type, presence: true
  validates :duration_minutes, presence: true, numericality: {greater_than: 0}
  validates :name, presence: {message: "/ Title cannot be blank"}
  validates :occurred_at, presence: true
  validate :occurred_at_not_in_future

  private

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
#  id               :bigint           not null, primary key
#  duration_hours   :integer          not null
#  duration_minutes :integer          not null
#  learning_type    :integer          default("other")
#  name             :string           not null
#  occurred_at      :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_learning_hours_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
