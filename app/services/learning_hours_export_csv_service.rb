require "csv"

class LearningHoursExportCsvService
  attr_reader :learning_hours

  def initialize(learning_hours)
    @learning_hours = learning_hours
  end

  def perform
    CSV.generate(headers: true) do |csv|
      csv << filtered_learning_hours.keys.map(&:to_s).map(&:titleize)
      @learning_hours.each do |learning_hour|
        csv << filtered_learning_hours(learning_hour).values
      end
    end
  end

  private

  def get_duration(learning_hour = nil)
    return "0:00" unless learning_hour
    "#{learning_hour.duration_hours}:#{learning_hour.duration_minutes}"
  end

  def filtered_learning_hours(learning_hour = nil)
    {
      volunteer_name: learning_hour&.user&.display_name,
      learning_hours_title: learning_hour&.name,
      learning_hours_type: learning_hour&.learning_hour_type&.name,
      duration: get_duration(learning_hour),
      date_of_learning: learning_hour&.occurred_at&.strftime("%F")
    }
  end
end
