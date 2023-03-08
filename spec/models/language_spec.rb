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
end
