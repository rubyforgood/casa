require "rails_helper"
require "csv"

RSpec.describe LearningHoursReport, type: :model do
  describe "#to_csv" do
    context "when there are learning hours" do
      it "includes all learning hours" do
        casa_org = build(:casa_org)
        users = create_list(:user, 3, casa_org: casa_org)
        learning_hours =
          [
            create(:learning_hour, user: users[0]),
            create(:learning_hour, user: users[1], learning_type: :movie),
            create(:learning_hour, user: users[2], learning_type: :webinar)
          ]
        result = CSV.parse(described_class.new(casa_org.id).to_csv)

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
