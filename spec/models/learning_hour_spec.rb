require "rails_helper"

RSpec.describe LearningHour, type: :model do
  it "has a title" do
    learning_hour = build_stubbed(:learning_hour, name: nil)
    expect(learning_hour).to_not be_valid
    expect(learning_hour.errors[:name]).to eq(["/ Title cannot be blank"])
  end

  it "has a learning_hour_type" do
    learning_hour = build_stubbed(:learning_hour, learning_hour_type: nil)
    expect(learning_hour).to_not be_valid
    expect(learning_hour.errors[:learning_hour_type]).to eq(["must exist"])
  end

  context "duration_hours is zero" do
    it "has a duration in minutes that is greater than 0" do
      learning_hour = build_stubbed(:learning_hour, duration_hours: 0, duration_minutes: 0)
      expect(learning_hour).to_not be_valid
      expect(learning_hour.errors[:duration_minutes]).to eq(["and hours (total duration) must be greater than 0"])
    end
  end

  context "duration_hours is greater than zero" do
    it "has a duration in minutes that is greater than 0" do
      learning_hour = build_stubbed(:learning_hour, duration_hours: 1, duration_minutes: 0)
      expect(learning_hour).to be_valid
      expect(learning_hour.errors[:duration_minutes]).to eq([])
    end
  end

  it "has an occurred_at date" do
    learning_hour = build_stubbed(:learning_hour, occurred_at: nil)
    expect(learning_hour).to_not be_valid
    expect(learning_hour.errors[:occurred_at]).to eq(["can't be blank"])
  end

  it "has date that is not in the future" do
    learning_hour = build_stubbed(:learning_hour, occurred_at: 1.day.from_now.strftime("%d %b %Y"))
    expect(learning_hour).to_not be_valid
  end

  it "does not require learning_hour_topic if casa_org learning_hour_topic disabled" do
    learning_hour = build_stubbed(:learning_hour, learning_hour_topic: nil)
    expect(learning_hour).to be_valid
  end

  it "requires learning_hour_topic if casa_org learning_hour_topic enabled" do
    casa_org = build(:casa_org, learning_topic_active: true)
    user = build(:user, casa_org: casa_org)
    learning_hour = build(:learning_hour, user: user)
    expect(learning_hour).to_not be_valid
    expect(learning_hour.errors[:learning_hour_topic]).to eq(["can't be blank"])
  end

  describe "scopes" do
    let(:casa_org_1) { build(:casa_org) }
    let(:casa_org_2) { build(:casa_org) }

    let(:casa_admin) { create(:casa_admin, display_name: "Supervisor", casa_org: casa_org_1) }
    let(:supervisor) { create(:supervisor, display_name: "Supervisor", casa_org: casa_org_1) }
    let(:volunteer1) { create(:volunteer, display_name: "Volunteer 1", casa_org: casa_org_1) }
    let(:volunteer2) { create(:volunteer, display_name: "Volunteer 2", casa_org: casa_org_1) }
    let(:volunteer3) { create(:volunteer, display_name: "Volunteer 3", casa_org: casa_org_2) }

    before do
      supervisor.volunteers << volunteer1
    end

    let!(:learning_hours) do
      [
        create(:learning_hour, user: volunteer1, duration_hours: 1, duration_minutes: 0),
        create(:learning_hour, user: volunteer1, duration_hours: 2, duration_minutes: 0),
        create(:learning_hour, user: volunteer2, duration_hours: 1, duration_minutes: 0),
        create(:learning_hour, user: volunteer2, duration_hours: 3, duration_minutes: 0),
        create(:learning_hour, user: volunteer3, duration_hours: 1, duration_minutes: 0)
      ]
    end

    describe ".supervisor_volunteers_learning_hours" do
      subject(:supervisor_volunteers_learning_hours) { described_class.supervisor_volunteers_learning_hours(supervisor.id) }
      context "with specified supervisor" do
        it "returns the total time spent for supervisor's volunteers" do
          expect(supervisor_volunteers_learning_hours.length).to eq(1)
          expect(supervisor_volunteers_learning_hours.first.total_time_spent).to eq(180)
        end
      end
    end

    describe ".all_volunteers_learning_hours" do
      subject(:all_volunteers_learning_hours) { described_class.all_volunteers_learning_hours(casa_admin.casa_org_id) }

      it "returns the total time spent for all volunteers" do
        expect(all_volunteers_learning_hours.length).to eq(2)
        expect(all_volunteers_learning_hours.last.total_time_spent).to eq(240)
      end
    end
  end
end
