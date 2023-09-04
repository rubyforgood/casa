# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocalTimeComponent, type: :component do
  it "render correct date from user local time" do
    component = described_class.new(format: 12, unix_timestamp: 1693825843)
    render_inline(component)
    expect(page).to have_text("September 04, 2023")
  end

  it "does not render correct date from user local time" do
    component = described_class.new(format: 12, unix_timestamp: 1693825843)
    render_inline(component)
    expect(page).to_not have_text("September 06, 2023")
  end
end
