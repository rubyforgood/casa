require "rails_helper"

RSpec.describe "checklist_items/destroy", type: :system do
  let(:casa_admin) { create(:casa_admin) }
  let(:checklist_item) { create(:checklist_item) }
  let(:hearing_type) { create(:hearing_type, checklist_items: [checklist_item]) }

  before do
    sign_in casa_admin
    visit edit_hearing_type_path(hearing_type)
  end

  it "deletes checklist items", :aggregate_failures do
    click_on "Delete", match: :first

    expect(page).to have_text("Checklist item was successfully deleted.")
    expect(page).not_to have_text(checklist_item.category)
    expect(page).not_to have_text(checklist_item.description)

    click_on "Submit"
    current_date = Time.new.strftime("%m/%d/%Y")
    expect(page).to have_text("Updated #{current_date}")
  end
end
