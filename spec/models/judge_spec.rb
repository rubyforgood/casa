require "rails_helper"

RSpec.describe Judge do
  it { is_expected.to belong_to(:casa_org) }
  it { is_expected.to validate_presence_of(:name) }

  describe ".for_organization" do
    subject { described_class.for_organization(casa_org) }

    let(:casa_org) { create(:casa_org) }

    it "returns only records matching the specified organization" do
      casa_org_2 = create(:casa_org)
      record_1 = create(:judge, casa_org:)
      record_2 = create(:judge, casa_org: casa_org_2)

      expect(subject).to contain_exactly(record_1)
      expect(subject).not_to include(record_2)
    end
  end

  describe "default scope" do
    it "orders alphabetically by name" do
      judge1 = create(:judge, name: "Gamma")
      judge2 = create(:judge, name: "Alpha")
      judge3 = create(:judge, name: "Epsilon")

      expect(described_class.all).to contain_exactly(judge2, judge3, judge1)
    end
  end
end
