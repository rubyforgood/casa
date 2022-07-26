require "rails_helper"

RSpec.describe LearningHoursExportCsvService do
  let!(:user) { create(:user) }

  let!(:learning_hour) do
    create(:learning_hour,
      duration_hours: 2,
      duration_minutes: 30,
      occurred_at: "2022-06-20")
  end

  describe "#perform" do
    let(:result) { described_class.new(LearningHour.all).perform }

    it "returns a csv as string with larning hours" do
      expect(result).to eq("Volunteer Name,Learning Hours Title,Learning Hours Type,Duration,Date Of Learning\n" \
        "#{user.display_name},#{learning_hour.name},#{learning_hour.learning_type},2:30,2022-06-20\n")
    end
  end
end
