# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dialog::GroupComponent, type: :component do
  it "renders a native dialog wired to the modal controller" do
    render_inline(described_class.new(label: "Delete this?")) { "body" }

    expect(page).to have_css("div[data-controller='modal'] > dialog[data-modal-target='dialog']")
    expect(page).to have_css("dialog[aria-label='Delete this?']", text: "body")
  end

  it "defaults to the medium panel and centering-friendly panel classes" do
    render_inline(described_class.new) { "x" }

    expect(page).to have_css("dialog.max-w-md.rounded-2xl.p-0")
  end

  it "accepts a size, id, and a trigger slot" do
    render_inline(described_class.new(size: :lg, id: "my-dialog")) do |c|
      c.with_trigger { "<button type=\"button\">Open</button>".html_safe }
      "body"
    end

    expect(page).to have_css("dialog#my-dialog.max-w-lg")
    expect(page).to have_button("Open")
  end

  it "wires extra controllers, auto-open, and extra data onto the wrapper" do
    render_inline(described_class.new(open_on_connect: true, controllers: "local-storage-reset", data: {local_storage_reset_key_value: "k"})) { "x" }

    wrapper = page.find("div[data-controller]")
    expect(wrapper["data-controller"]).to eq("modal local-storage-reset")
    expect(wrapper["data-modal-open-on-connect-value"]).to eq("true")
    expect(wrapper["data-local-storage-reset-key-value"]).to eq("k")
  end
end
