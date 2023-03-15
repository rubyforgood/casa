require "rails_helper"

RSpec.describe Language, type: :model do
  let(:organization) { create(:casa_org) }
  let!(:language) { create(:language, name: "Spanish", casa_org: organization) }

  it { is_expected.to belong_to(:casa_org) }
  it { is_expected.to have_many(:user_languages) }
  it { is_expected.to have_many(:users).through(:user_languages) }

  it { is_expected.to validate_presence_of(:name) }

  it "validates uniqueness of language for an organization" do
    subject = build(:language, name: "spanish", casa_org: organization)

    expect(subject).not_to be_valid
  end

  context "when calling valid?" do
    it "removes surrounding spaces from the name attribute" do
      subject = build(:language, name: "  spanish  ", casa_org: organization)
      subject.valid?
      expect(subject.name).to eq "spanish"
    end

    it "removes surrounding spaces from the name attribute but leaves in middle spaces" do
      subject = build(:language, name: " Western Punjabi ", casa_org: organization)
      subject.valid?
      expect(subject.name).to eq "Western Punjabi"
    end
  end
end
