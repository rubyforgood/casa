require "rails_helper"

RSpec.describe SvgSanitizerService do
  let(:result) { described_class.sanitize(file) }

  describe "when receiving a svg file" do
    let(:file) { fixture_file_upload("unsafe_svg.svg", "image/svg+xml") }

    it "removes script tags" do
      expect(result.read).not_to match("script")
    end
  end

  describe "when not receiving a svg file" do
    let(:file) { fixture_file_upload("company_logo.png", "image/png") }

    it "returns the file without changes" do
      expect(result).to eq(file)
    end
  end

  describe "when receiving nil" do
    let(:file) { nil }

    it "returns nil" do
      expect(result).to be_nil
    end
  end
end
