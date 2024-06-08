require "rails_helper"

RSpec.describe MileageRate, type: :model do
  subject { build(:mileage_rate) }

  it { is_expected.to belong_to(:casa_org) }
  it { is_expected.to validate_presence_of(:effective_date) }
  it { is_expected.to validate_presence_of(:casa_org) }
  it { is_expected.to validate_presence_of(:amount) }

  describe "for_organization" do
    let!(:casa_org_1) { create(:casa_org) }
    let!(:casa_org_2) { create(:casa_org) }
    let!(:record_1) { create(:mileage_rate, casa_org: casa_org_1) }
    let!(:record_2) { create(:mileage_rate, casa_org: casa_org_2) }

    it "returns only records matching the specified organization" do
      expect(described_class.for_organization(casa_org_1)).to eq([record_1])
      expect(described_class.for_organization(casa_org_2)).to eq([record_2])
    end
  end

  context "#effective_date" do
    it "cannot be before 1/1/1989" do
      mileage_rate = build_stubbed(:mileage_rate, effective_date: "1984-01-01".to_date)
      expect(mileage_rate).to_not be_valid
      expect(mileage_rate.errors[:effective_date]).to eq(["cannot be prior to 1/1/1989."])
    end

    it "cannot be more than one year in the future" do
      mileage_rate = build_stubbed(:mileage_rate, effective_date: 367.days.from_now)
      expect(mileage_rate).to_not be_valid
      expect(mileage_rate.errors[:effective_date]).to eq(["must not be more than one year in the future."])
    end

    it "is valid in the past after 1/1/1989" do
      mileage_rate = build_stubbed(:mileage_rate, effective_date: "1997-08-29".to_date)
      expect(mileage_rate).to be_valid
      expect(mileage_rate.errors[:effective_date]).to eq([])
    end

    it "is valid today" do
      mileage_rate = build_stubbed(:mileage_rate, effective_date: DateTime.now)
      expect(mileage_rate).to be_valid
      expect(mileage_rate.errors[:effective_date]).to eq([])
    end

    it "is unique within is_active and casa_org" do
      effective_date = Date.new(2020, 1, 1)
      casa_org = create(:casa_org)
      create(:mileage_rate, effective_date: effective_date, is_active: true, casa_org: casa_org)
      expect do
        create(:mileage_rate, effective_date: effective_date, is_active: true, casa_org: create(:casa_org))
      end.not_to raise_error
      expect do
        create(:mileage_rate, effective_date: effective_date, is_active: false, casa_org: casa_org)
      end.not_to raise_error
      expect do
        create(:mileage_rate, effective_date: effective_date, is_active: true, casa_org: casa_org)
      end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Effective date must not have duplicate active dates")
    end
  end
end
