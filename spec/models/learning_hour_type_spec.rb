require "rails_helper"

RSpec.describe LearningHourType, type: :model do
  it { is_expected.to belong_to(:casa_org) }
  it { is_expected.to validate_presence_of(:name) }

  it "has a valid factory" do
    expect(build(:learning_hour_type).valid?).to be true
  end

  it "has unique names for the specified organization" do
    casa_org_1 = create(:casa_org)
    casa_org_2 = create(:casa_org)
    create(:learning_hour_type, casa_org: casa_org_1, name: "Book")
    expect {
      create(:learning_hour_type, casa_org: casa_org_1, name: "Book")
    }.to raise_error(ActiveRecord::RecordInvalid)
    expect {
      create(:learning_hour_type, casa_org: casa_org_1, name: "Book    ")
    }.to raise_error(ActiveRecord::RecordInvalid)
    expect {
      create(:learning_hour_type, casa_org: casa_org_1, name: "book")
    }.to raise_error(ActiveRecord::RecordInvalid)
    expect {
      create(:learning_hour_type, casa_org: casa_org_2, name: "Book")
    }.to_not raise_error
  end

  describe "for_organization" do
    let!(:casa_org_1) { create(:casa_org) }
    let!(:casa_org_2) { create(:casa_org) }
    let!(:record_1) { create(:learning_hour_type, casa_org: casa_org_1) }
    let!(:record_2) { create(:learning_hour_type, casa_org: casa_org_2) }

    it "returns only records matching the specified organization" do
      expect(described_class.for_organization(casa_org_1)).to eq([record_1])
      expect(described_class.for_organization(casa_org_2)).to eq([record_2])
    end
  end

  describe "default scope" do
    let(:casa_org) { create(:casa_org) }

    it "orders alphabetically by position and then name" do
      create(:learning_hour_type, casa_org: casa_org, name: "Book")
      create(:learning_hour_type, casa_org: casa_org, name: "Webinar")
      create(:learning_hour_type, casa_org: casa_org, name: "Other", position: 99)
      create(:learning_hour_type, casa_org: casa_org, name: "YouTube")

      type_names = %w[Book Webinar YouTube Other]
      expect(described_class.for_organization(casa_org).map(&:name)).to eq(type_names)
    end
  end
end
