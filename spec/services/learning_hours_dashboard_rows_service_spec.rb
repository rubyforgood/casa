require "rails_helper"

RSpec.describe LearningHoursDashboardRowsService do
  describe "#perform" do
    subject(:rows) { described_class.new(user, learning_hours_scope).perform }

    let(:learning_hours_scope) { LearningHour.none }

    context "when the user is a volunteer" do
      let(:user) { create(:volunteer) }
      let(:learning_hours_scope) { LearningHour.where(user: user) }
      let!(:learning_hour) { create(:learning_hour, user: user) }

      it "returns the authorized learning hours scope" do
        expect(rows).to contain_exactly(learning_hour)
      end
    end

    context "when the user is a supervisor" do
      let(:casa_org) { create(:casa_org) }
      let(:user) do
        create(
          :supervisor,
          casa_org: casa_org,
          volunteers: [volunteer_with_hours, zero_hour_volunteer]
        )
      end
      let(:volunteer_with_hours) do
        create(:volunteer, casa_org: casa_org, display_name: "Volunteer With Hours")
      end
      let(:zero_hour_volunteer) do
        create(:volunteer, casa_org: casa_org, display_name: "Zero Hour Volunteer")
      end

      before do
        create(:learning_hour, user: volunteer_with_hours, duration_hours: 1, duration_minutes: 25)
        create(:learning_hour, user: volunteer_with_hours, duration_hours: 2, duration_minutes: 35)
      end

      it "returns learning hour totals for assigned volunteers with hours" do
        volunteer_row = rows.find { |row| row.user_id == volunteer_with_hours.id }

        expect(volunteer_row.display_name).to eq("Volunteer With Hours")
        expect(volunteer_row.total_time_spent).to eq(240)
      end

      it "returns zero-hour rows for assigned volunteers without learning hours" do
        zero_hour_row = rows.find { |row| row.user_id == zero_hour_volunteer.id }

        expect(zero_hour_row.display_name).to eq("Zero Hour Volunteer")
        expect(zero_hour_row.total_time_spent).to eq(0)
      end
    end

    context "when the user is a casa admin" do
      let(:casa_org) { create(:casa_org) }
      let(:user) { create(:casa_admin, casa_org: casa_org) }
      let(:volunteer) { create(:volunteer, casa_org: casa_org, display_name: "Admin Volunteer") }

      before do
        create(:learning_hour, user: volunteer, duration_hours: 3, duration_minutes: 15)
      end

      it "returns learning hour totals for the admin organization" do
        expect(rows.length).to eq(1)
        expect(rows.first.user_id).to eq(volunteer.id)
        expect(rows.first.display_name).to eq("Admin Volunteer")
        expect(rows.first.total_time_spent).to eq(195)
      end
    end
  end
end
