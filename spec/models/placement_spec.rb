require "rails_helper"

RSpec.describe Placement do
  subject(:placement) { build_stubbed(:placement) }

  specify do
    expect(subject).to belong_to(:placement_type).optional(false)
    expect(subject).to belong_to(:creator).optional(false)
    expect(subject).to belong_to(:casa_case).optional(false)
  end

  specify "placement_started_at validations" do
    placement.placement_started_at = "1988-12-31".to_date
    expect(placement).not_to be_valid
    expect(placement.errors[:placement_started_at]).to eq(["cannot be prior to 1/1/1989."])

    placement.placement_started_at = 367.days.from_now
    expect(placement).not_to be_valid
    expect(placement.errors[:placement_started_at]).to eq(["must not be more than one year in the future."])

    placement.placement_started_at = "1989-01-02".to_date
    expect(placement).to be_valid
    expect(placement.errors[:placement_started_at]).to eq([])

    placement.placement_started_at = DateTime.now
    expect(placement).to be_valid
    expect(placement.errors[:placement_started_at]).to eq([])
  end
end
