require "rails_helper"
require "csv"

RSpec.describe LearningHoursReport, type: :model do
  let!(:casa_org) { create(:casa_org) }
  let!(:users) { create_list(:user, 3, casa_org: casa_org) }

  describe "#to_csv" do
    let(:result) { CSV.parse(described_class.new(casa_org.id).to_csv) }

    context "when there are learning hours" do
      let!(:learning_hours) do
        [
          create(:learning_hour, user: users[0]),
          create(:learning_hour, user: users[1], learning_type: :movie),
          create(:learning_hour, user: users[2], learning_type: :webinar)
        ]
      end

      it "includes all learning hours" do
        expect(result.length).to eq(learning_hours.length + 1)
        learning_hours.each_with_index do |learning_hour, index|
          wait_for_csv_parse(learning_hour, result[index + 1], %i[name learning_type])
          expect(result[index + 1]).to eq([
            learning_hour.user.display_name,
            learning_hour.name,
            learning_hour.learning_type,
            "#{learning_hour.duration_hours}:#{learning_hour.duration_minutes}",
            learning_hour.occurred_at.strftime("%F")
          ])
        end
      end
    end

    context "when there are no learning hours" do
      let(:result) { CSV.parse(described_class.new(casa_org.id).to_csv) }

      it "returns only the header" do
        expect(result.length).to eq(1)
        expect(result[0]).to eq([
          "Volunteer Name",
          "Learning Hours Title",
          "Learning Hours Type",
          "Duration",
          "Date Of Learning"
        ])
      end
    end
  end
end
