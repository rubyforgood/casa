require "rails_helper"

RSpec.describe Banner do
  subject(:banner) { build_stubbed(:banner, casa_org:) }

  let(:casa_org) { create(:casa_org) }

  describe "#valid?" do
    it "does not allow multiple active banners for same organization" do
      create(:banner, casa_org: casa_org)

      expect(banner).not_to be_valid
    end

    it "does allow multiple active banners for different organization" do
      create(:banner, casa_org: create(:casa_org))

      expect(banner).to be_valid
    end

    it "does not allow an expiry date set in the past" do
      banner.expires_at = 1.hour.ago
      expect(banner).not_to be_valid
    end

    it "does not allow content to be empty" do
      banner.content = nil
      expect(banner).not_to be_valid
    end
  end

  describe "#expired?" do
    it "is false when expires_at is nil" do
      banner.expires_at = nil

      expect(banner).not_to be_expired
    end

    it "is false when expires_at is set but is in the future" do
      banner.expires_at = 7.days.from_now

      expect(banner).not_to be_expired
    end

    it "is true when expires_at is set but is in the past" do
      banner = create(:banner, expires_at: nil)
      banner.update_columns(expires_at: 1.hour.ago)
      expect(banner).to be_expired
    end

    it "sets active to false when banner is expired" do
      banner = create(:banner, expires_at: 1.hour.from_now)
      expect(banner.active).to be true
      banner.expires_at = 1.hour.ago
      banner.expired?
      expect(banner.active).to be false
    end
  end

  describe "#expires_at_in_time_zone" do
    it "can shift time by timezone for equivalent times" do
      banner = build_stubbed(:banner, expires_at: "2024-06-13 12:00:00 UTC")

      expires_at_in_pacific_time = banner.expires_at_in_time_zone("America/Los_Angeles")
      expect(expires_at_in_pacific_time.to_s).to eq("2024-06-13 05:00:00 -0700")

      expires_at_in_eastern_time = banner.expires_at_in_time_zone("America/New_York")
      expect(expires_at_in_eastern_time.to_s).to eq("2024-06-13 08:00:00 -0400")

      expect(expires_at_in_pacific_time).to eq(expires_at_in_eastern_time)
    end
  end
end
