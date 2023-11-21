module LearningHoursHelper
  def format_time(minutes)
    hours = minutes / 60
    remaining_minutes = minutes % 60
    "#{hours} hours #{remaining_minutes} minutes"
  end
end