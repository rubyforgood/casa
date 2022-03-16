require "rails_helper"

RSpec.describe Judge, type: :model do
  it { is_expected.to belong_to(:casa_org) }
  it { is_expected.to validate_presence_of(:name) }

  it "has a valid factory" do
    expect(build(:judge).valid?).to be true
  end

  describe "for_organization" do
    let!(:casa_org_1) { create(:casa_org) }
    let!(:casa_org_2) { create(:casa_org) }
    let!(:record_1) { create(:judge, casa_org: casa_org_1) }
    let!(:record_2) { create(:judge, casa_org: casa_org_2) }

    it "returns only records matching the specified organization" do
      expect(described_class.for_organization(casa_org_1)).to eq([record_1])
      expect(described_class.for_organization(casa_org_2)).to eq([record_2])
    end
  end

  describe "default scope" do
    let(:casa_org) { create(:casa_org) }
    let!(:judges) do
      5.times.map { create(:judge, casa_org: casa_org) }
    end

    it "orders alphabetically by name" do
      expect(described_class.for_organization(casa_org)).to eq(judges.sort_by(&:name))
    end
  end
end
