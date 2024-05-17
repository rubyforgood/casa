# frozen_string_literal: true

require "rails_helper"

RSpec.describe Modal::FooterComponent, type: :component do
  it "renders the footer with content" do
    render_inline(Modal::FooterComponent.new(klass: "example-class")) do
      "Footer Content"
    end

    expect(page).to have_css("div.modal-footer.example-class")
    expect(page).to have_css("div.modal-footer button.btn.btn-secondary", text: "Close")
    expect(page).to have_text("Footer Content")
  end

  it "does not render the footer if content missing" do
    render_inline(Modal::FooterComponent.new)

    expect(page).not_to have_css("div.modal-footer")
  end

  it "doesn't render if render_check is false" do
    render_inline(Modal::FooterComponent.new(render_check: false)) do
      "Footer Content"
    end

    expect(page).not_to have_css("div.modal-footer")
  end
end
