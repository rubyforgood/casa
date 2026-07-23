# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dialog::HeaderComponent, type: :component do
  it "renders the title and a close button by default" do
    render_inline(described_class.new(title: "Download court report"))

    expect(page).to have_css("h2", text: "Download court report")
    expect(page).to have_css("button[aria-label='Close']")
  end

  it "renders a danger status badge when an icon is given" do
    render_inline(described_class.new(title: "Delete?", icon: "bi bi-exclamation-triangle", variant: :danger))

    expect(page).to have_css("span.rounded-full.bg-rose-100 i.bi-exclamation-triangle")
  end

  it "can omit the close button" do
    render_inline(described_class.new(title: "x", closable: false))

    expect(page).to have_no_css("button[aria-label='Close']")
  end
end
