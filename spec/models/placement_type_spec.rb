require "rails_helper"

RSpec.describe PlacementType, type: :model do
  let!(:object) { create(:placement_type) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:casa_org) }

  describe "for_organization" do
    let!(:casa_org_1) { create(:casa_org) }
    let!(:casa_org_2) { create(:casa_org) }
    let!(:placement_type_1) { create(:placement_type, casa_org: casa_org_1) }
    let!(:placement_type_2) { create(:placement_type, casa_org: casa_org_2) }

    it "returns only records matching the specified organization" do
      expect(described_class.for_organization(casa_org_1)).to eq([placement_type_1])
      expect(described_class.for_organization(casa_org_2)).to eq([placement_type_2])
    end
  end
end
