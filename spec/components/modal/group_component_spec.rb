# frozen_string_literal: true

require "rails_helper"

RSpec.describe Modal::GroupComponent, type: :component do
  before do
    @component = Modal::GroupComponent.new(id: "exampleModal", klass: "example-class")
  end

  it "renders the modal group with header, body, and footer" do
    @component.with_header(id: "header-id") { "Example Header" }
    @component.with_body { "Example Body" }
    @component.with_footer { "Example Footer" }
    render_inline(@component)

    expect(page).to have_css("div.modal.fade.example-class#exampleModal")
    expect(page).to have_css("div.modal-dialog.modal-dialog-centered")
    expect(page).to have_css("div.modal-content")
    expect(page).to have_text("Example Header")
    expect(page).to have_text("Example Body")
    expect(page).to have_text("Example Footer")
  end

  it "renders the modal group with only a header" do
    @component.with_header(id: "header-id") { "Example Header" }
    render_inline(@component)

    expect(page).to have_css("div.modal.fade.example-class#exampleModal")
    expect(page).to have_css("div.modal-dialog.modal-dialog-centered")
    expect(page).to have_css("div.modal-content")
    expect(page).to have_text("Example Header")
    expect(page).not_to have_css("div.modal-body")
    expect(page).not_to have_css("div.modal-footer")
  end

  it "renders the modal group with only a body" do
    @component.with_body { "Example Body" }
    render_inline(@component)

    expect(page).to have_css("div.modal.fade.example-class#exampleModal")
    expect(page).to have_css("div.modal-dialog.modal-dialog-centered")
    expect(page).to have_css("div.modal-content")
    expect(page).to have_text("Example Body")
    expect(page).not_to have_css("div.modal-header")
    expect(page).not_to have_css("div.modal-footer")
  end

  it "doesn't render anything if no content provided" do
    render_inline(@component)

    expect(page).not_to have_css("div.modal.fade.example-class#exampleModal")
    expect(page).not_to have_css("div.modal-dialog.modal-dialog-centered")
    expect(page).not_to have_css("div.modal-content")
  end

  it "doesn't render if render_check is false" do
    @component = Modal::GroupComponent.new(id: "exampleModal", klass: "example-class", render_check: false)
    @component.with_header(id: "header-id") { "Example Header" }
    @component.with_body { "Example Body" }
    @component.with_footer { "Example Footer" }
    render_inline(@component)

    expect(page).not_to have_css("div.modal.fade.example-class#exampleModal")
    expect(page).not_to have_css("div.modal-dialog.modal-dialog-centered")
    expect(page).not_to have_css("div.modal-content")
  end
end
