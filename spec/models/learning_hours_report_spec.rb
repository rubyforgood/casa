require "rails_helper"
require "csv"

RSpec.describe LearningHoursReport, type: :model do
  describe "#to_csv" do
    context "when there are learning hours" do
      it "includes all learning hours" do
        casa_org = build(:casa_org)
        users = create_list(:user, 3, casa_org: casa_org)
        learning_hour_type = create(:learning_hour_type)
        learning_hours =
          [
            create(:learning_hour, user: users[0], learning_hour_type: learning_hour_type),
            create(:learning_hour, user: users[1], learning_type: :movie, learning_hour_type: learning_hour_type),
            create(:learning_hour, user: users[2], learning_type: :webinar, learning_hour_type: learning_hour_type)
          ]
        result = CSV.parse(described_class.new(casa_org.id).to_csv)

        expect(result.length).to eq(learning_hours.length + 1)

        result.each_with_index do |row, index|
          next if index.zero?
          expect(row[0]).to eq learning_hours[index - 1].user.display_name
          expect(row[1]).to eq learning_hours[index - 1].name
          expect(row[2]).to eq learning_hours[index - 1].learning_hour_type.name
          expect(row[3]).to eq "#{learning_hours[index - 1].duration_hours}:#{learning_hours[index - 1].duration_minutes}"
          expect(row[4]).to eq learning_hours[index - 1].occurred_at.strftime("%F")
        end
      end
    end

    context "when there are no learning hours" do
      it "returns only the header" do
        casa_org = build(:casa_org)
        result = CSV.parse(described_class.new(casa_org.id).to_csv)

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
