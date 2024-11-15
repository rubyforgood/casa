require "rails_helper"

RSpec.describe OtherDutiesHelper, type: :helper do
  describe "#duration_minutes" do
    it "returns remainder if duration_minutes is set" do
      other_duty = build(:other_duty, duration_minutes: 80)
      expect(helper.duration_minutes(other_duty)).to eq(20)
    end

    it "returns zero if duration_minutes is zero" do
      other_duty = build(:other_duty, duration_minutes: 0)
      expect(helper.duration_minutes(other_duty)).to eq(0)
    end

    it "returns zero if duration_minutes is nil" do
      other_duty = build(:other_duty, duration_minutes: nil)
      expect(helper.duration_minutes(other_duty)).to eq(0)
    end
  end

  describe "#duration_hours" do
    it "returns minutes if duration_minutes is set" do
      other_duty = build(:other_duty, duration_minutes: 80)
      expect(helper.duration_hours(other_duty)).to eq(1)
    end

    it "returns zero if duration_minutes is zero" do
      other_duty = build(:other_duty, duration_minutes: 0)
      expect(helper.duration_hours(other_duty)).to eq(0)
    end

    it "returns zero if duration_minutes is nil" do
      other_duty = build(:other_duty, duration_minutes: nil)
      expect(helper.duration_hours(other_duty)).to eq(0)
    end
  end
end
