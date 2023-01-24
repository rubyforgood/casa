require "rails_helper"

RSpec.describe "checklist_items/edit", type: :view do
  let(:admin) { build_stubbed(:casa_admin) }

  before do
    assign :hearing_type, HearingType.new(id: 1)
    assign :checklist_item, ChecklistItem.new
    sign_in admin

    render template: "checklist_items/edit"
  end

  it "shows edit checklist item page title" do
    expect(rendered).to have_text("Edit this checklist item")
  end

  it "shows edit checklist item form" do
    expect(rendered).to have_selector("input", id: "checklist_item_category")
    expect(rendered).to have_selector("input", id: "checklist_item_description")
    expect(rendered).to have_selector("input", id: "checklist_item_mandatory")
    expect(rendered).to have_selector(:link_or_button, "Submit")
  end

  it "requires category text field" do
    expect(rendered).to have_selector("input[required=required]", id: "checklist_item_category")
  end

  it "requires description text field" do
    expect(rendered).to have_selector("input[required=required]", id: "checklist_item_description")
  end
end
