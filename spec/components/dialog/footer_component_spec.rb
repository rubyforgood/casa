# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dialog::FooterComponent, type: :component do
  it "right-aligns actions by default" do
    render_inline(described_class.new) { "btns" }

    expect(page).to have_css("div.justify-end.border-t", text: "btns")
  end

  it "can center a single action" do
    render_inline(described_class.new(align: :center)) { "btns" }

    expect(page).to have_css("div.justify-center")
  end
end
