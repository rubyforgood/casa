require "rails_helper"

RSpec.describe MileageRate do
  subject(:mileage_rate) { build_stubbed(:mileage_rate) }

  specify do
    expect(mileage_rate).to belong_to(:casa_org).optional(false)
    expect(mileage_rate).to validate_presence_of(:effective_date)
    expect(mileage_rate).to validate_presence_of(:amount)
  end

  describe ".for_organization scope" do
    subject { described_class.for_organization(casa_org) }

    let(:casa_org) { create(:casa_org) }
    let(:other_casa_org) { create(:casa_org) }
    let!(:record) { create(:mileage_rate, casa_org:) }
    let!(:other_record) { create(:mileage_rate, casa_org: other_casa_org) }

    it "returns only records matching the specified organization" do
      expect(subject).to contain_exactly(record)
      expect(subject).not_to include(other_record)
    end
  end

  describe "#effective_date" do
    specify do
      mileage_rate.effective_date = "1988-12-31".to_date
      expect(mileage_rate).not_to be_valid
      expect(mileage_rate.errors[:effective_date]).to eq(["cannot be prior to 1/1/1989."])

      mileage_rate.effective_date = 367.days.from_now
      expect(mileage_rate).not_to be_valid
      expect(mileage_rate.errors[:effective_date]).to eq(["must not be more than one year in the future."])

      mileage_rate.effective_date = "1989-01-01".to_date
      expect(mileage_rate).to be_valid
      expect(mileage_rate.errors[:effective_date]).to eq([])

      mileage_rate.effective_date = Date.current
      expect(mileage_rate).to be_valid
      expect(mileage_rate.errors[:effective_date]).to eq([])
    end

    it "is unique within is_active and casa_org" do
      effective_date = Date.current
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
