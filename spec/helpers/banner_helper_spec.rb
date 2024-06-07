require "rails_helper"

RSpec.describe BannerHelper do
  describe "#conditionally_add_hidden_class" do
    it "returns d-none if current banner is inactive" do
      current_organization = double
      allow(helper).to receive(:current_organization).and_return(current_organization)
      banner = double(id: 1)
      assign(:banner, banner)

      allow(current_organization).to receive(:has_alternate_active_banner?).and_return(true)

      expect(helper.conditionally_add_hidden_class(false)).to eq("d-none")
    end

    it "returns d-none if current banner is active and org does not have an alternate active banner" do
      current_organization = double
      allow(helper).to receive(:current_organization).and_return(current_organization)
      banner = double(id: 1)
      assign(:banner, banner)

      allow(current_organization).to receive(:has_alternate_active_banner?).and_return(false)

      expect(helper.conditionally_add_hidden_class(true)).to eq("d-none")
    end

    it "returns nil if current banner is active and org has an alternate active banner" do
      current_organization = double
      allow(helper).to receive(:current_organization).and_return(current_organization)
      banner = double(id: 1)
      assign(:banner, banner)

      allow(current_organization).to receive(:has_alternate_active_banner?).and_return(true)

      expect(helper.conditionally_add_hidden_class(true)).to eq(nil)
    end
  end

  describe "#banner_expiration_time_in_words" do
    let(:banner) { create(:banner, expires_at: expires_at) }

    context "when expires_at isn't set" do
      let(:expires_at) { nil }

      it "returns No" do
        expect(helper.banner_expiration_time_in_words(banner)).to eq("No Expiration")
      end
    end

    context "when expires_at is in the future" do
      let(:expires_at) { 7.days.from_now }

      it "returns a word description of how far in the future" do
        expect(helper.banner_expiration_time_in_words(banner)).to eq("in 7 days")
      end
    end

    context "when expires_at is in the past" do
      let(:expires_at) { 1.day.from_now }

      it "returns yes" do
        banner
        travel 2.days
        expect(helper.banner_expiration_time_in_words(banner)).to eq("Expired")
      end
    end
  end
end
