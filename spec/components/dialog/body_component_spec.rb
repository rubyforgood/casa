# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dialog::BodyComponent, type: :component do
  it "uses the panel padding by default" do
    render_inline(described_class.new) { "hi" }

    expect(page).to have_css("div.px-5.py-4", text: "hi")
  end

  it "centers for the status layout and merges extra classes" do
    render_inline(described_class.new(centered: true, classes: "space-y-4")) { "hi" }

    expect(page).to have_css("div.text-center.space-y-4")
  end
end
