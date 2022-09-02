require "rails_helper"

RSpec.describe "checklist_items/new", type: :system do
  let(:casa_admin) { create(:casa_admin) }
  let(:hearing_type) { create(:hearing_type) }

  before do
    sign_in casa_admin
    visit new_hearing_type_checklist_item_path(hearing_type)
  end

  it "creates with valid data", :aggregate_failures do
    fill_in "Category", with: "checklist item category"
    fill_in "Description", with: "checklist item description"
    click_on "Submit"

    expect(page).to have_text("Checklist item was successfully created.")
    expect(page).to have_text("checklist item category")
    expect(page).to have_text("checklist item description")
    expect(page).to have_text("Optional")

    click_on "Submit"
    current_date = Time.new.strftime("%m/%d/%Y")
    expect(page).to have_text("Updated #{current_date}")
  end

  it "rejects with invalid data" do
    fill_in "Category", with: ""
    fill_in "Description", with: ""
    click_on "Submit"

    expect(page).to have_text("Add a new checklist item")
  end
end
