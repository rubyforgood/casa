# frozen_string_literal: true

require "rails_helper"

RSpec.describe Modal::HeaderComponent, type: :component do
  it "renders the header with text and icon" do
    render_inline(Modal::HeaderComponent.new(text: "Example Header", id: "modalHeader", icon: "example-icon", klass: "example-class"))

    expect(page).to have_css("div.modal-header.example-class")
    expect(page).to have_css("div.modal-header h1#modalHeader-label.modal-title.fs-5")
    expect(page).to have_css("div.modal-header h1#modalHeader-label i.lni.mr-10.lni-example-icon")
    expect(page).to have_text("Example Header")
    expect(page).to have_css("div.modal-header button.btn-close")
  end

  it "renders the header with only text" do
    render_inline(Modal::HeaderComponent.new(text: "Example Header", id: "modalHeader"))

    expect(page).to have_css("div.modal-header")
    expect(page).to have_css("div.modal-header h1#modalHeader-label.modal-title.fs-5")
    expect(page).not_to have_css("div.modal-header i")
    expect(page).to have_text("Example Header")
    expect(page).to have_css("div.modal-header button.btn-close")
  end

  it "renders the header with content" do
    render_inline(Modal::HeaderComponent.new(id: "modalHeader")) do
      "Header Content"
    end

    expect(page).to have_css("div.modal-header")
    expect(page).to have_text("Header Content")
    expect(page).to have_css("div.modal-header button.btn-close")
  end

  it "content overrides text" do
    render_inline(Modal::HeaderComponent.new(id: "modalHeader", text: "Missing")) do
      "Header Content"
    end

    expect(page).to have_css("div.modal-header")
    expect(page).to have_text("Header Content")
    expect(page).to_not have_text("Missing")
    expect(page).to have_css("div.modal-header button.btn-close")
  end

  it "doesn't render anything if both text and content are absent" do
    render_inline(Modal::HeaderComponent.new(id: "modalHeader"))

    expect(page).not_to have_css("div.modal-header")
  end

  it "doesn't render if render_check is false" do
    render_inline(Modal::HeaderComponent.new(text: "Example Header", id: "modalHeader", render_check: false))

    expect(page).not_to have_css("div.modal-header")
  end
end
