require "rails_helper"

RSpec.describe ContactType, type: :model do
  let(:contact_type_group) { create(:contact_type_group, name: "Group 1") }
  let(:contact_type) { create(:contact_type, name: "Type 1", contact_type_group: contact_type_group) }

  describe "#create" do
    it "does have a unique name" do
      new_contact_type = create(:contact_type, name: "Type 1", contact_type_group: contact_type_group)
      expect(subject).to validate_presence_of(:name)
      expect(new_contact_type).to validate_uniqueness_of(:name).scoped_to(:contact_type_group_id)
        .with_message("should be unique per contact type group")
    end
  end

  describe "#update" do
    it "can update to a valid name" do
      contact_type.name = "New name"
      contact_type.save
      expect(contact_type.name).to eq("New name")
    end

    it "can't update to an invalid name" do
      contact_type.name = nil
      expect { contact_type.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
    end

    it "can update contact type group" do
      new_group = create(:contact_type_group, name: "New contact group")
      contact_type.contact_type_group_id = new_group.id
      expect(contact_type.contact_type_group.name).to eq("New contact group")
    end

    it "can deactivate contact type" do
      contact_type.active = false
      expect(contact_type.active?).to be_falsey
    end
  end

  describe "for_organization" do
    let!(:casa_org_1) { create(:casa_org) }
    let!(:casa_org_2) { create(:casa_org) }
    let!(:contact_type_group_record_1) { create(:contact_type_group, casa_org: casa_org_1) }
    let!(:contact_type_group_record_2) { create(:contact_type_group, casa_org: casa_org_2) }
    let!(:record_1) { create(:contact_type, contact_type_group: contact_type_group_record_1) }
    let!(:record_2) { create(:contact_type, contact_type_group: contact_type_group_record_2) }

    it "returns only records matching the specified organization" do
      expect(described_class.for_organization(casa_org_1)).to eq([record_1])
      expect(described_class.for_organization(casa_org_2)).to eq([record_2])
    end
  end

  describe ".alphabetically scope" do
    subject { described_class.alphabetically }

    let!(:contact_type1) { create(:contact_type, name: "Aunt Uncle or Cousin") }
    let!(:contact_type2) { create(:contact_type, name: "Parent") }

    it "orders alphabetically", :aggregate_failures do
      expect(subject.first).to eq(contact_type1)
      expect(subject.last).to eq(contact_type2)
    end
  end
end
