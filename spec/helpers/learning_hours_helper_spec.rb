require "rails_helper"

RSpec.describe LearningHoursHelper, type: :helper do
  describe "#format_time" do
    it "formats time correctly for positive values" do
      expect(helper.format_time(120)).to eq("2 hours 0 minutes")
      expect(helper.format_time(90)).to eq("1 hours 30 minutes")
      expect(helper.format_time(75)).to eq("1 hours 15 minutes")
    end

    it "formats time correctly for zero minutes" do
      expect(helper.format_time(0)).to eq("0 hours 0 minutes")
    end

    it "formats time correctly for large values" do
      expect(helper.format_time(360)).to eq("6 hours 0 minutes")
      expect(helper.format_time(1800)).to eq("30 hours 0 minutes")
    end
  end
end
