# frozen_string_literal: true

require "rails_helper"

RSpec.describe TruncatedTextComponent, type: :component do
  let(:text) { "This is some sample text." }

  context "when text is provided" do
    it "renders the component with the provided text" do
      render_inline(TruncatedTextComponent.new(text))

      expect(page).to have_css(".truncation-container")
      expect(page).to have_css("span.line-clamp-1", text: text)
      expect(page).to have_css('a[data-truncated-text-target="moreButton"]', text: "[read more]")
      expect(page).to have_css('a[data-truncated-text-target="hideButton"]', text: "[hide]")
    end
  end

  context "when no text is provided but content is present" do
    it "renders the component with the provided content" do
      render_inline(TruncatedTextComponent.new) { "Content from block" }

      expect(page).to have_css(".truncation-container")
      expect(page).to have_css("span.line-clamp-1", text: "Content from block")
      expect(page).to have_css('a[data-truncated-text-target="moreButton"]', text: "[read more]")
      expect(page).to have_css('a[data-truncated-text-target="hideButton"]', text: "[hide]")
    end
  end

  context "when render_check is false" do
    it "does not render the component" do
      render_inline(TruncatedTextComponent.new(text, render_check: false))

      expect(page).to_not have_css("div")
    end
  end

  context "when text and content are both not present" do
    it "does not render the component" do
      render_inline(TruncatedTextComponent.new)

      expect(page).to_not have_css("div")
    end
  end
end
