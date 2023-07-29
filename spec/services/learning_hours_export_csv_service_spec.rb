require "rails_helper"

RSpec.describe LearningHoursExportCsvService do
  let!(:user) { create(:user) }
  let!(:learning_hour_type) { create(:learning_hour_type) }
  let!(:learning_hour) do
    create(:learning_hour,
      duration_hours: 2,
      duration_minutes: 30,
      occurred_at: "2022-06-20",
      learning_hour_type: learning_hour_type)
  end

  describe "#perform" do
    let(:result) { described_class.new(LearningHour.all).perform }

    it "returns a csv as a string starting with the learning hours headers" do
      csv_headers = "Volunteer Name,Learning Hours Title,Learning Hours Type,Duration,Date Of Learning\n"

      expect(result).to start_with(csv_headers)
    end

    it "returns a csv as a string ending with the learning hours values" do
      csv_values = "#{user.display_name},#{learning_hour.name},#{learning_hour.learning_hour_type.name}," \
        "2:30,2022-06-20\n"

      if learning_hour.name.include? ","
        csv_values.gsub!(learning_hour.name, '"' + learning_hour.name + '"')
      end

      expect(result).to end_with(csv_values)
    end
  end
end
