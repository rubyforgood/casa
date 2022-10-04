require "rails_helper"

RSpec.describe OtherDuty, type: :model do
  it { is_expected.to belong_to(:creator) }

  it "validates presence of notes" do
    duty = build(:other_duty, notes: nil)
    expect(duty).to_not be_valid
    expect(duty.errors[:notes]).to eq(["can't be blank"])
  end

  it "cannot be saved without a user" do
    other_duty = OtherDuty.new
    other_duty.creator = nil
    expect { other_duty.save!(validate: false) }.to raise_error ActiveRecord::NotNullViolation
  end
end
