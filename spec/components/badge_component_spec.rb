# frozen_string_literal: true

require "rails_helper"

RSpec.describe BadgeComponent, type: :component do
  it "renders a success badge with only required parameters" do
    component = described_class.new(text: "success", type: :success)

    render_inline(component)
    expect(page).to have_css("span.bg-success", text: "success")
    expect(page).to have_css(".text-uppercase")
    expect(page).not_to have_css(".text-dark")
    expect(page).not_to have_css(".rounded-pill")
    expect(page).to have_css(".my-1")
  end

  it "renders a danger badge changing default parameters" do
    component = described_class.new(text: "danger", type: :danger, rounded: true, margin: false)

    render_inline(component)
    expect(page).to have_css("span.bg-danger", text: "danger")
    expect(page).to have_css(".text-uppercase")
    expect(page).not_to have_css(".text-dark")
    expect(page).to have_css(".rounded-pill")
    expect(page).not_to have_css(".my-1")
  end

  it "renders the dark text badges" do
    dark_text_badges = ["warning", "light"]
    dark_text_badges.each do |badge|
      component = described_class.new(text: badge, type: badge)

      render_inline(component)
      expect(page).to have_css("span.bg-#{badge}", text: badge)
      expect(page).to have_css(".text-dark")
    end
  end
end
