require "rails_helper"

RSpec.describe CustomOrgLink, type: :model do
  it { is_expected.to belong_to :casa_org }
  it { is_expected.to validate_presence_of :text }
  it { is_expected.to validate_presence_of :url }
  it { is_expected.to validate_length_of(:text).is_at_most described_class::TEXT_MAX_LENGTH }
  it { is_expected.to validate_inclusion_of(:active).in_array [true, false] }

  describe "url validation - only allow http or https schemes" do
    it { is_expected.to allow_value("http://example.com").for(:url) }
    it { is_expected.to allow_value("https://example.com").for(:url) }

    it { is_expected.not_to allow_value("ftp://example.com").for(:url) }
    it { is_expected.not_to allow_value("example.com").for(:url) }
    it { is_expected.not_to allow_value("some arbitrary string").for(:url) }
  end
end
