require "rails_helper"

RSpec.describe "checklist_items/new" do
  let(:casa_org) { create(:casa_org) }
  let(:casa_admin) { create(:casa_admin, casa_org:) }
  let(:hearing_type) { create(:hearing_type, casa_org:) }
  let(:current_date) { Date.current.strftime("%m/%d/%Y") }

  before do
    sign_in casa_admin
    visit new_hearing_type_checklist_item_path(hearing_type)
  end

  it "creates with valid data", :aggregate_failures do
    expect(hearing_type.checklist_items.size).to eq(0)

    fill_in "Category", with: "checklist item category"
    fill_in "Description", with: "checklist item description"
    click_on "Submit"

    expect(page).to have_text("Checklist item was successfully created.")
    expect(page).to have_text("checklist item category")
    expect(page).to have_text("checklist item description")
    expect(page).to have_text("Optional")

    expect(hearing_type.reload.checklist_items.size).to eq(1)
    checklist_item = hearing_type.checklist_items.first
    expect(checklist_item.category).to eq("checklist item category")
    expect(checklist_item.description).to eq("checklist item description")
    expect(checklist_item.mandatory).to be false
  end

  it "rejects with invalid data" do
    fill_in "Category", with: ""
    fill_in "Description", with: ""
    click_on "Submit"

    expect(page).to have_text("Category can't be blank")
    expect(page).to have_text("Description can't be blank")

    expect(hearing_type.reload.checklist_items.size).to eq(0)
  end
end
