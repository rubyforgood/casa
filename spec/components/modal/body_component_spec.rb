# frozen_string_literal: true

require "rails_helper"

RSpec.describe Modal::BodyComponent, type: :component do
  it "renders the body with text" do
    render_inline(Modal::BodyComponent.new(text: "Example Body", klass: "example-class"))

    expect(page).to have_css("div.modal-body.example-class")
    expect(page).to have_css("div.modal-body p", text: "Example Body")
  end

  it "renders the body with multiple paragraphs" do
    render_inline(Modal::BodyComponent.new(text: ["Paragraph 1", "Paragraph 2"]))

    expect(page).to have_css("div.modal-body p", text: "Paragraph 1")
    expect(page).to have_css("div.modal-body p", text: "Paragraph 2")
  end

  it "renders the body with content" do
    render_inline(Modal::BodyComponent.new) do
      "Content Override"
    end

    expect(page).to have_css("div.modal-body", text: "Content Override")
  end

  it "renders the body with content and overrides text" do
    render_inline(Modal::BodyComponent.new(text: "Example Body")) do
      "Content Override"
    end

    expect(page).to have_css("div.modal-body", text: "Content Override")
    expect(page).not_to have_css("div.modal-body", text: "Example Body")
  end

  it "does not render if text and content missing" do
    render_inline(Modal::BodyComponent.new)

    expect(page).not_to have_css("div.modal-body")
  end

  it "doesn't render if render_check is false" do
    render_inline(Modal::BodyComponent.new(text: "Example Body", render_check: false))

    expect(page).not_to have_css("div.modal-body")
  end
end
