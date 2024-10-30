require "rails_helper"

RSpec.describe HearingType do
  specify do
    expect(subject).to belong_to(:casa_org)
    expect(subject).to have_many(:checklist_items)

    expect(subject).to validate_presence_of(:name)
  end

  describe ".for_organization" do
    subject { described_class.for_organization(casa_org) }

    let(:casa_org) { create(:casa_org) }
    let(:other_org) { create(:casa_org) }
    let!(:record) { create(:hearing_type, casa_org:) }
    let!(:other_record) { create(:hearing_type, casa_org: other_org) }

    it "returns only records matching the specified organization" do
      expect(subject).to contain_exactly(record)
      expect(subject).not_to include(other_record)
    end
  end

  describe "default scope" do
    let(:casa_org) { create(:casa_org) }
    let(:hearing_types) { create_list(:hearing_type, 5, casa_org:) }

    it "orders alphabetically by name" do
      expect(described_class.all).to eq(hearing_types.sort_by(&:name))
    end
  end
end
