require "rails_helper"

RSpec.describe Placement, type: :model do
  let!(:object) { create(:placement) }

  it { is_expected.to belong_to(:placement_type) }
  it { is_expected.to belong_to(:creator) }
  it { is_expected.to belong_to(:casa_case) }

  context "placement_started_at" do
    it "cannot be before 1/1/1989" do
      placement = build_stubbed(:placement, placement_started_at: "1984-01-01".to_date)
      expect(placement).to_not be_valid
      expect(placement.errors[:placement_started_at]).to eq(["cannot be prior to 1/1/1989."])
    end

    it "cannot be more than one year in the future" do
      placement = build_stubbed(:placement, placement_started_at: 367.days.from_now)
      expect(placement).to_not be_valid
      expect(placement.errors[:placement_started_at]).to eq(["must not be more than one year in the future."])
    end

    it "is valid in the past after 1/1/1989" do
      placement = build_stubbed(:placement, placement_started_at: "1997-08-29".to_date)
      expect(placement).to be_valid
      expect(placement.errors[:placement_started_at]).to eq([])
    end

    it "is valid today" do
      placement = build_stubbed(:placement, placement_started_at: DateTime.now)
      expect(placement).to be_valid
      expect(placement.errors[:placement_started_at]).to eq([])
    end
  end
end
