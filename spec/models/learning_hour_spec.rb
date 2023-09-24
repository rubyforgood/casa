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
      expect(learning_hour.errors[:duration_minutes]).to eq(["must be greater than 0"])
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
end
