# frozen_string_literal: true

require "rails_helper"

RSpec.describe Modal::OpenLinkComponent, type: :component do
  it "renders the link with text and icon" do
    render_inline(Modal::OpenLinkComponent.new(target: "myModal", text: "Example Text", icon: "example-icon", klass: "example-class"))

    expect(page).to have_css("a[href='#'][role='button'][class='btn example-class'][data-bs-toggle='modal'][data-bs-target='#myModal']")
    expect(page).to have_css("a i.lni.mr-10.lni-example-icon")
    expect(page).to have_text("Example Text")
  end

  it "renders the link with only text" do
    render_inline(Modal::OpenLinkComponent.new(target: "myModal", text: "Example Text"))

    expect(page).to have_css("a[href='#'][role='button'][class='btn '][data-bs-toggle='modal'][data-bs-target='#myModal']")
    expect(page).not_to have_css("a i")
    expect(page).to have_text("Example Text")
  end

  it "renders the link with content" do
    render_inline(Modal::OpenLinkComponent.new(target: "myModal")) do
      "Example Text"
    end

    expect(page).to have_css("a[href='#'][role='button'][class='btn '][data-bs-toggle='modal'][data-bs-target='#myModal']")
    expect(page).not_to have_css("a i")
    expect(page).to have_text("Example Text")
  end

  it "content overrides text" do
    render_inline(Modal::OpenLinkComponent.new(target: "myModal", text: "Override")) do
      "Example Text"
    end

    expect(page).to have_css("a[href='#'][role='button'][class='btn '][data-bs-toggle='modal'][data-bs-target='#myModal']")
    expect(page).not_to have_css("a i")
    expect(page).to have_text("Example Text")
    expect(page).to_not have_text("Override")
  end

  it "doesn't render anything if both text and content are absent" do
    render_inline(Modal::OpenLinkComponent.new(target: "myModal"))

    expect(page).not_to have_css("a")
  end

  it "doesn't render if render_check is false" do
    render_inline(Modal::OpenLinkComponent.new(target: "myModal", text: "Example Text", render_check: false))

    expect(page).not_to have_css("a")
  end
end
