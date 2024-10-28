require "rails_helper"

RSpec.describe ContactTypeGroup do
  it "does not have duplicate names" do
    org_id = create(:casa_org).id
    create_contact_type_group = -> { create(:contact_type_group, {name: "Test1", casa_org_id: org_id}) }
    create_contact_type_group.call
    expect { create_contact_type_group.call }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken")
  end

  describe "for_organization" do
    subject { described_class.for_organization(casa_org) }

    let(:casa_org) { create(:casa_org) }
    let(:other_casa_org) { create(:casa_org) }
    let!(:org_record) { create(:contact_type_group, casa_org:) }
    let!(:other_org_record) { create(:contact_type_group, casa_org: other_casa_org) }

    it "returns only records matching the specified organization" do
      expect(subject).to contain_exactly(org_record)
      expect(subject).not_to include(other_org_record)
    end
  end

  describe ".alphabetically scope" do
    subject { described_class.alphabetically }

    let!(:family_contact_type_group) { create(:contact_type_group, name: "Family") }
    let!(:placement_contact_type_group) { create(:contact_type_group, name: "Placement") }

    it "orders alphabetically", :aggregate_failures do
      expect(subject).to eq([family_contact_type_group, placement_contact_type_group])
    end
  end
end
