class LearningHour < ApplicationRecord
  belongs_to :user
  belongs_to :learning_hour_type
  belongs_to :learning_hour_topic, optional: true
  has_one :casa_org, through: :user

  validates :duration_minutes, presence: true
  validates :duration_minutes, numericality: {greater_than: 0, message: "and hours (total duration) must be greater than 0"}, if: :zero_duration_hours?
  validates :name, presence: {message: "/ Title cannot be blank"}
  validates :occurred_at, presence: true
  validate :occurred_at_not_in_future
  validates :occurred_at, comparison: {
    greater_than_or_equal_to: "1989-01-01".to_date,
    message: "is not valid: Occurred on Date cannot be prior to 1/1/1989.",
    allow_nil: true
  }
  validates :learning_hour_topic, presence: true, if: :user_org_learning_topic_enable?

  # `occurred_in` is optional so the Pundit scopes keep meaning "everything this user may see".
  # The roster passes a range; without one these totals are all-time, which is what the roster
  # column used to show while its header said "this year".
  #
  # A DATE range has to be widened to cover the whole final day. `occurred_at` is a datetime, so
  # `Date.current.beginning_of_year..Date.current` serialises to `BETWEEN '2026-01-01' AND
  # '2026-07-31'` and Postgres reads that upper bound as MIDNIGHT -- measured: an entry logged at 09:00
  # today was excluded, so "Time completed since January 1" silently ignored anything logged today.
  # DateTime subclasses Date in Ruby, hence the explicit check: an explicit time range is left alone.
  scope :occurred_in, ->(range) {
    next all unless range

    if range.first.instance_of?(Date)
      where(occurred_at: range.first.beginning_of_day..range.last.end_of_day)
    else
      where(occurred_at: range)
    end
  }

  scope :supervisor_volunteers_learning_hours, ->(supervisor_id, range = nil) {
    joins(user: :supervisor_volunteer)
      .where(supervisor_volunteers: {supervisor_id: supervisor_id})
      .occurred_in(range)
      .select("users.id as user_id, users.display_name, SUM(learning_hours.duration_minutes + learning_hours.duration_hours * 60) AS total_time_spent")
      .group("users.display_name, users.id")
      .order("users.display_name")
  }

  scope :all_volunteers_learning_hours, ->(casa_admin_org_id, range = nil) {
    joins(:user)
      .where(users: {casa_org_id: casa_admin_org_id})
      .occurred_in(range)
      .select("users.id as user_id, users.display_name, SUM(learning_hours.duration_minutes + learning_hours.duration_hours * 60) AS total_time_spent")
      .group("users.display_name, users.id")
      .order("users.display_name")
  }

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

  def user_org_learning_topic_enable?
    user.casa_org.learning_topic_active
  end
end

# == Schema Information
#
# Table name: learning_hours
#
#  id                     :bigint           not null, primary key
#  duration_hours         :integer          not null
#  duration_minutes       :integer          not null
#  name                   :string           not null
#  occurred_at            :datetime         not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  learning_hour_topic_id :bigint
#  learning_hour_type_id  :bigint
#  user_id                :bigint           not null
#
# Indexes
#
#  index_learning_hours_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (learning_hour_type_id => learning_hour_types.id)
#  fk_rails_...  (user_id => users.id)
#
