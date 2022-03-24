module LearningHoursHelper
  def duration_hours(learning_hour)
    learning_hour.duration_hours.to_i.div(60)
  end

  def duration_minutes(learning_hour)
    learning_hour.duration_minutes.to_i.remainder(60)
  end
end
