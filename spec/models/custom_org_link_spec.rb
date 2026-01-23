require "rails_helper"

RSpec.describe CustomOrgLink, type: :model do
  it { is_expected.to belong_to :casa_org }
  it { is_expected.to validate_presence_of :text }
  it { is_expected.to validate_presence_of :url }
  it { is_expected.to validate_length_of(:text).is_at_most described_class::TEXT_MAX_LENGTH }

  describe "#trim_name" do
    let(:casa_org) { create(:casa_org) }

    context "when text is present" do
      it "trims leading and trailing whitespace from text" do
        custom_link = build(:custom_org_link, casa_org: casa_org, text: "  Example Text  ")
        custom_link.save
        expect(custom_link.text).to eq("Example Text")
      end
    end
  end

  describe "url validation - only allow http or https schemes" do
    it { is_expected.to allow_value("http://example.com").for(:url) }
    it { is_expected.to allow_value("https://example.com").for(:url) }

    it { is_expected.not_to allow_value("ftp://example.com").for(:url) }
    it { is_expected.not_to allow_value("example.com").for(:url) }
    it { is_expected.not_to allow_value("some arbitrary string").for(:url) }
  end

  describe "#active" do
    it "only allows true or false" do
      casa_org = build(:casa_org)

      expect(build(:custom_org_link, casa_org: casa_org, active: false)).to be_valid
      expect(build(:custom_org_link, casa_org: casa_org, active: true)).to be_valid
      expect(build(:custom_org_link, casa_org: casa_org, active: nil)).to be_invalid
    end
  end
end
