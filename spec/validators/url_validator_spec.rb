require "rails_helper"

RSpec.describe UrlValidator, type: :validator do
  let(:validatable_class) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :website

      validates :website, url: true
    end
  end

  subject(:record) { validatable_class.new(website: url) }

  context "with a valid http url" do
    let(:url) { "http://example.com" }

    it "is valid" do
      expect(record).to be_valid
    end
  end

  context "with a valid https url" do
    let(:url) { "https://example.com" }

    it "is valid" do
      expect(record).to be_valid
    end
  end

  context "with a scheme that is not http or https" do
    let(:url) { "ftp://example.com" }

    it "is invalid with a scheme error", :aggregate_failures do
      expect(record).not_to be_valid
      expect(record.errors[:website]).to include("scheme invalid - only http, https allowed")
    end
  end

  context "with a missing host" do
    let(:url) { "http://" }

    it "is invalid with a missing host error", :aggregate_failures do
      expect(record).not_to be_valid
      expect(record.errors[:website]).to include("host cannot be blank")
    end
  end

  context "with a malformed URI" do
    let(:url) { "http://exa mple.com" }

    it "is invalid with a format error", :aggregate_failures do
      expect(record).not_to be_valid
      expect(record.errors[:website]).to include("format is invalid")
    end
  end

  context "with a custom :scheme option" do
    let(:validatable_class) do
      Class.new do
        include ActiveModel::Model

        attr_accessor :website

        validates :website, url: {scheme: "ftp"}
      end
    end

    context "when the url uses the allowed custom scheme" do
      let(:url) { "ftp://example.com" }

      it "is valid" do
        expect(record).to be_valid
      end
    end

    context "when the url uses the default http scheme" do
      let(:url) { "http://example.com" }

      it "is invalid with a scheme error mentioning the custom scheme", :aggregate_failures do
        expect(record).not_to be_valid
        expect(record.errors[:website]).to include("scheme invalid - only ftp allowed")
      end
    end
  end
end
