require "rails_helper"

RSpec.describe Banner, type: :model do
  describe "#valid?" do
    let(:casa_org) { create(:casa_org) }
    let(:supervisor) {create(:supervisor, casa_org: casa_org) }

    it "does not allow multiple active banners for same organization" do
      create(:banner, casa_org: casa_org, user: supervisor)

      banner = build(:banner, casa_org: casa_org, user: supervisor)
      expect(banner).to_not be_valid
    end

    it "does allow multiple active banners for different organization" do
      create(:banner, casa_org: casa_org, user: supervisor)

      another_org = create(:casa_org)
      another_supervisor = create(:supervisor, casa_org: another_org)
      banner = build(:banner, casa_org: another_org, user: another_supervisor)
      expect(banner).to be_valid
    end

    it "does not allow an expiry date set in the past" do
      banner = build(:banner, casa_org: casa_org, user: supervisor, expires_at: 1.hour.ago)
      expect(banner).to_not be_valid
    end

    it "allows an expiry date set in the future" do
      banner = build(:banner, casa_org: casa_org, user: supervisor, expires_at: 1.day.from_now)
      expect(banner).to be_valid
    end
  end

  describe "#expired?" do
    it "is false when expires_at is nil" do
      banner = create(:banner, expires_at: nil)

      expect(banner).not_to be_expired
    end

    it "is false when expires_at is set but is in the future" do
      banner = create(:banner, expires_at: 7.days.from_now)

      expect(banner).not_to be_expired
    end

    it "is true when expires_at is set but is in the past" do
      banner = create(:banner, expires_at: 1.hour.from_now)
      travel 2.hours
      expect(banner).to be_expired
    end
  end

  describe "#expires_at_in_time_zone" do
    it "can shift time by timezone for equivalent times" do
      banner = create(:banner, expires_at: "2024-06-13 12:00:00 UTC")

      expires_at_in_pacific_time = banner.expires_at_in_time_zone("America/Los_Angeles")
      expect(expires_at_in_pacific_time.to_s).to eq("2024-06-13 05:00:00 -0700")

      expires_at_in_eastern_time = banner.expires_at_in_time_zone("America/New_York")
      expect(expires_at_in_eastern_time.to_s).to eq("2024-06-13 08:00:00 -0400")

      expect(expires_at_in_pacific_time).to eq(expires_at_in_eastern_time)
    end
  end
end
