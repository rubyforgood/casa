require "rails_helper"

RSpec.describe "checklist_items/edit", type: :system do
  let(:casa_admin) { create(:casa_admin) }
  let(:hearing_type) { create(:hearing_type) }
  let(:checklist_item) { create(:checklist_item, hearing_type: hearing_type) }

  before do
    sign_in casa_admin
    visit edit_hearing_type_checklist_item_path(hearing_type, checklist_item)
  end

  it "edits with valid data", :aggregate_failures do
    fill_in "Category", with: "checklist item category EDIT"
    fill_in "Description", with: "checklist item description EDIT"
    check "Mandatory"
    click_on "Submit"

    expect(page).to have_text("Checklist item was successfully updated.")
    expect(page).to have_text("checklist item category EDIT")
    expect(page).to have_text("checklist item description EDIT")
    expect(page).to have_text("Yes")

    click_on "Submit"
    current_date = Time.new.strftime("%m/%d/%Y")
    expect(page).to have_text("Updated #{current_date}")
  end

  it "rejects with invalid data" do
    fill_in "Category", with: ""
    fill_in "Description", with: ""
    click_on "Submit"

    expect(page).to have_text("Edit this checklist item")
  end
end
