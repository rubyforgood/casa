# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocalTimeComponent, type: :component do

  it "render time, date, and time zone in user local time" do
    component = described_class.new(format: 12, unix_timestamp: 1693825843)
    expect(component.local_time[:date]).to have_text("September 04, 2023")
    expect(component.local_time[:time]).to have_text("04:10 PM")
    expect(component.local_time[:zone]).to have_text("PKT")
  end

  it "does not render time in passed time zone" do
    component = described_class.new(format: 12, unix_timestamp: 1693825843)
    expect(component.local_time[:time]).to_not have_text("11:10 AM")
    expect(component.local_time[:zone]).to_not have_text("UTC")
  end
end
