require "rails_helper"

class MockController < ApplicationController
  include Users::TimeZone
end

RSpec.describe MockController, type: :controller do
  let(:browser_time_zone) { "America/Los_Angeles" }
  let(:default_time_zone) { "Eastern Time (US & Canada)" }
  let(:time_date) { Time.zone.now }
  before do
    allow(controller).to receive(:cookies).and_return(browser_time_zone: browser_time_zone)
  end

  describe "#browser_time_zone" do
    it "returns the matching time zone" do
      browser_tz = ActiveSupport::TimeZone.find_tzinfo(browser_time_zone)
      matching_zone = ActiveSupport::TimeZone.all.find { |zone| zone.tzinfo == browser_tz }
      expect(controller.browser_time_zone).to eq(matching_zone || Time.zone)
    end

    context "when browser_time_zone cookie is not set" do
      before do
        allow(controller).to receive(:cookies).and_return({})
      end

      it "returns the default time zone" do
        expect(controller.browser_time_zone).to eq(Time.zone)
      end
    end

    context "when browser_time_zone cookie contains an invalid value" do
      before do
        allow(controller).to receive(:cookies).and_return(browser_time_zone: "Invalid/Timezone")
      end

      it "returns the default time zone" do
        expect(controller.browser_time_zone).to eq(Time.zone)
      end
    end
  end

  describe "#to_user_timezone" do
    context "when browser time zone has an invalid value" do
      before do
        allow(controller).to receive(:cookies).and_return(browser_time_zone: "Invalid/Timezone")
      end

      it "returns the default time even if browser time zone has an invalid value" do
        expected_time = time_date.in_time_zone(default_time_zone)
        returned_time = controller.to_user_timezone(time_date.in_time_zone(Time.zone))
        expect(returned_time).to eq(expected_time)
      end
    end

    context "when browser time zone is not set" do
      before do
        allow(controller).to receive(:cookies).and_return({})
      end

      it "returns the default timezone" do
        expect(controller.to_user_timezone(time_date)).to eq(time_date.in_time_zone(default_time_zone))
      end
    end

    context "when invalid param is sent" do
      it "returns the empty string for nil param" do
        expect(controller.to_user_timezone(nil)).to eq("")
      end

      it "returns empty string if empty string param provided" do
        expect(controller.to_user_timezone("")).to eq("")
      end

      it "returns nil for invalid date string" do
        expect(controller.to_user_timezone("invalid-date")).to eq(nil)
      end
    end
  end
end
