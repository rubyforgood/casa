require "rails_helper"

RSpec.describe Address, type: :model do
  describe "validate associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "#structured?" do
    it "is false for a legacy content-only address" do
      expect(build(:address, content: "123 Main St").structured?).to be false
    end

    it "is true when any structured part is present" do
      expect(build(:address, content: nil, city: "Springfield").structured?).to be true
    end
  end

  describe "content composition" do
    it "composes content from the structured parts on save" do
      address = create(:address, content: nil, line_1: "123 Main St", line_2: "Apt 4", city: "Springfield", state: "IL", zip: "62701")
      expect(address.content).to eq "123 Main St, Apt 4, Springfield, IL 62701"
    end

    it "omits blank parts when composing" do
      address = create(:address, content: nil, line_1: "123 Main St", city: "Springfield", state: "IL", zip: "62701")
      expect(address.content).to eq "123 Main St, Springfield, IL 62701"
    end

    it "composes a line_1-only address back to exactly line_1 (backfill stability)" do
      address = create(:address, content: "legacy value", line_2: nil, line_1: "123 Main St")
      expect(address.content).to eq "123 Main St"
    end

    it "leaves legacy content untouched when no structured parts are set" do
      address = create(:address, content: "123 Legacy Rd")
      expect(address.content).to eq "123 Legacy Rd"
    end
  end
end
