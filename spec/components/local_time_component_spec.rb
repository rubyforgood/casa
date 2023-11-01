# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocalTimeComponent, type: :component do
  it "formats the date using strftime" do
    component = described_class.new(format: "%b %d, %Y", unix_timestamp: 1693825843, time_zone: ActiveSupport::TimeZone.new("Eastern Time (US & Canada)"))
    render_inline(component)
    expect(page).to have_text("Sep 04, 2023")
  end

  it "uses the time zone passed to it to format the time" do
    component = described_class.new(format: "%l:%M %p %Z", unix_timestamp: 1693825843, time_zone: ActiveSupport::TimeZone.new("Eastern Time (US & Canada)"))
    render_inline(component)
    expect(page).to have_text("7:10 AM EDT")

    component = described_class.new(format: "%l:%M %p %Z", unix_timestamp: 1693825843, time_zone: ActiveSupport::TimeZone.new("Central Time (US & Canada)"))
    render_inline(component)
    expect(page).to have_text("6:10 AM CDT")

    component = described_class.new(format: "%l:%M %p %Z", unix_timestamp: 1693825843, time_zone: ActiveSupport::TimeZone.new("Mountain Time (US & Canada)"))
    render_inline(component)
    expect(page).to have_text("5:10 AM MDT")

    component = described_class.new(format: "%l:%M %p %Z", unix_timestamp: 1693825843, time_zone: ActiveSupport::TimeZone.new("Pacific Time (US & Canada)"))
    render_inline(component)
    expect(page).to have_text("4:10 AM PDT")
  end

  it "has an unambigous detailed date as the title of the element" do
    component = described_class.new(format: "%l:%M %p %Z", unix_timestamp: 1693825843, time_zone: ActiveSupport::TimeZone.new("Central Time (US & Canada)"))
    render_inline(component)
    expect(page.find_css("span").attr("title").value).to have_text("Sep 04, 2023,  6:10 AM CDT")
  end
end
