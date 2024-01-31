require "rails_helper"
# require "contact_type_group"
require "./app/models/contact_type_group"

RSpec.describe ContactTypeGroup, type: :model do
  it "does not have duplicate names" do
    org_id = create(:casa_org).id
    create_contact_type_group = -> { create(:contact_type_group, {name: "Test1", casa_org_id: org_id}) }
    create_contact_type_group.call
    expect { create_contact_type_group.call }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken")
  end

  describe "for_organization" do
    let!(:casa_org_1) { create(:casa_org) }
    let!(:casa_org_2) { create(:casa_org) }
    let!(:record_1) { create(:contact_type_group, casa_org: casa_org_1) }
    let!(:record_2) { create(:contact_type_group, casa_org: casa_org_2) }

    it "returns only records matching the specified organization" do
      expect(described_class.for_organization(casa_org_1)).to eq([record_1])
      expect(described_class.for_organization(casa_org_2)).to eq([record_2])
    end
  end

  describe ".alphabetically scope" do
    subject { described_class.alphabetically }

    let!(:contact_type_group1) { create(:contact_type_group, name: "Family") }
    let!(:contact_type_group2) { create(:contact_type_group, name: "Placement") }

    it "orders alphabetically", :aggregate_failures do
      expect(subject.first).to eq(contact_type_group1)
      expect(subject.last).to eq(contact_type_group2)
    end
  end
end
