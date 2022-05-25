require "rails_helper"

RSpec.describe OtherDuty, type: :model do
  it { is_expected.to belong_to(:creator) }

  it "validates presence of notes" do
    duty = build(:other_duty, notes: nil)
    expect(duty).to_not be_valid
    expect(duty.errors[:notes]).to eq(["can't be blank"])
  end
end
