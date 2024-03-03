# frozen_string_literal: true

# spec/components/modal/open_button_component_spec.rb

require "rails_helper"

RSpec.describe Modal::OpenButtonComponent, type: :component do
  it "renders the button with text and icon" do
    render_inline(Modal::OpenButtonComponent.new(target: "myModal", text: "Example Text", icon: "example-icon", klass: "example-class"))

    expect(page).to have_css("button[type='button'][class='btn example-class'][data-bs-toggle='modal'][data-bs-target='#myModal']")
    expect(page).to have_css("button i.lni.mr-10.lni-example-icon")
    expect(page).to have_text("Example Text")
  end

  it "renders the button with only text" do
    render_inline(Modal::OpenButtonComponent.new(target: "myModal", text: "Example Text"))

    expect(page).to have_css("button[type='button'][class='btn '][data-bs-toggle='modal'][data-bs-target='#myModal']")
    expect(page).not_to have_css("button i")
    expect(page).to have_text("Example Text")
  end

  it "renders the button with content" do
    render_inline(Modal::OpenButtonComponent.new(target: "myModal")) do
      "Example Text"
    end

    expect(page).to have_css("button[type='button'][class='btn '][data-bs-toggle='modal'][data-bs-target='#myModal']")
    expect(page).not_to have_css("button i")
    expect(page).to have_text("Example Text")
  end

  it "content overrides text" do
    render_inline(Modal::OpenButtonComponent.new(target: "myModal", text: "Overwritten")) do
      "Example Text"
    end

    expect(page).to have_css("button[type='button'][class='btn '][data-bs-toggle='modal'][data-bs-target='#myModal']")
    expect(page).not_to have_css("button i")
    expect(page).to have_text("Example Text")
    expect(page).to_not have_text("Overwritten")
  end

  it "doesn't render anything if both text and content are absent" do
    render_inline(Modal::OpenButtonComponent.new(target: "myModal"))

    expect(page).not_to have_css("button")
  end

  it "doesn't render if render_check is false" do
    render_inline(Modal::OpenButtonComponent.new(target: "myModal", text: "Example Text", render_check: false))

    expect(page).not_to have_css("button")
  end
end
