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

  describe "occurred_at validation" do
    it "is not valid before 1989" do
      other_duty = OtherDuty.new(occurred_at: "1984-01-01".to_date)
      expect(other_duty.valid?).to be false
      expect(other_duty.errors[:occurred_at]).to eq(["is not valid. Occured on date cannot be prior to 1/1/1989."])
    end

    it "is not valid more than 1 year in the future" do
      other_duty = OtherDuty.new(occurred_at: 367.days.from_now)
      expect(other_duty.valid?).to be false
      expect(other_duty.errors[:occurred_at]).to eq(["is not valid. Occured on date must be within one year from today."])
    end

    it "is valid within one year in the future" do
      other_duty = OtherDuty.new(occurred_at: 6.months.from_now)
      other_duty.valid?
      expect(other_duty.errors[:occurred_at]).to eq([])
    end

    it "is valid in the past after 1989" do
      other_duty = OtherDuty.new(occurred_at: "1997-08-29".to_date)
      other_duty.valid?
      expect(other_duty.errors[:occurred_at]).to eq([])
    end
  end
end
