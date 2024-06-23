# frozen_string_literal: true

require "rails_helper"

RSpec.describe TruncatedTextComponent, type: :component do
  let(:text) { "This is some sample text." }
  let(:label) { "Label" }

  context "when text and a label is provided" do
    it "renders the component with the provided text" do
      render_inline(TruncatedTextComponent.new(text, label: label))

      expect(page).to have_css(".truncation-container")
      expect(page).to have_css("div.line-clamp-1", text: text)
      expect(page).to have_css("span.text-bold", text: label)
      expect(page).to have_css('a[data-truncated-text-target="moreButton"]', text: "[read more]")
      expect(page).to have_css('a[data-truncated-text-target="hideButton"]', text: "[hide]")
    end
  end

  context "when text is provided but a label is not" do
    it "renders the component with the provided content" do
      render_inline(TruncatedTextComponent.new(text))

      expect(page).to have_css(".truncation-container")
      expect(page).to have_css("div.line-clamp-1", text: text)
      expect(page).to_not have_css("span.text-bold", text: label)
      expect(page).to have_css('a[data-truncated-text-target="moreButton"]', text: "[read more]")
      expect(page).to have_css('a[data-truncated-text-target="hideButton"]', text: "[hide]")
    end
  end
end
