# frozen_string_literal: true

require "rails_helper"

RSpec.describe DropdownMenuComponent, type: :component do
  it "renders the dropdown menu with an icon and label" do
    render_inline(DropdownMenuComponent.new(menu_title: "Example", icon_name: "example-icon")) { "Example Content" }

    expect(page).to have_css("div.dropdown")
    expect(page).to have_css("button.btn.btn-secondary.dropdown-toggle span", text: "Example")
    expect(page).to have_css("button.btn.btn-secondary.dropdown-toggle i.lni.mr-10.lni-example-icon")
    expect(page).to have_css(".dropdown-menu", text: "Example Content")
  end

  it "renders the dropdown menu with a hidden label" do
    render_inline(DropdownMenuComponent.new(menu_title: "Example", icon_name: "example-icon", hide_label: true)) { "Example Content" }

    expect(page).to have_css("div.dropdown")
    expect(page).to have_css("button.btn.btn-secondary.dropdown-toggle span.sr-only", text: "Example")
    expect(page).to have_css("button.btn.btn-secondary.dropdown-toggle i.lni.mr-10.lni-example-icon")
    expect(page).to have_css(".dropdown-menu", text: "Example Content")
  end

  it "renders the dropdown menu with only a label and content" do
    render_inline(DropdownMenuComponent.new(menu_title: "Example Title")) { "Example Item" }

    expect(page).to have_css("div.dropdown")
    expect(page).to have_css("button.btn.btn-secondary.dropdown-toggle")
    expect(page).to have_css(".dropdown-menu", text: "Example Item")
  end

  it "doesn't render anything if no content provided" do
    render_inline(DropdownMenuComponent.new(menu_title: nil))

    expect(page).not_to have_css("div.dropdown")
  end

  it "renders the dropdown menu with additional classes" do
    render_inline(DropdownMenuComponent.new(menu_title: "Example", klass: "example-class")) { "Example Content" }

    expect(page).to have_css("div.dropdown.example-class")
  end

  it "doesn't render if render_check is false" do
    render_inline(DropdownMenuComponent.new(menu_title: "Example", render_check: false))

    expect(page).not_to have_css("div.dropdown")
  end
end
