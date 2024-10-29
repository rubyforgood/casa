require "rails_helper"

RSpec.describe "checklist_items/destroy" do
  let(:casa_org) { create(:casa_org) }
  let(:casa_admin) { create(:casa_admin, casa_org:) }
  let(:hearing_type) { create(:hearing_type, :with_checklist_items, casa_org:) }
  let(:checklist_item) { hearing_type.checklist_items.first }

  before do
    sign_in casa_admin
  end

  it "deletes checklist items", :aggregate_failures do
    visit edit_hearing_type_path(hearing_type)
    expect(page).to have_text(checklist_item.category)
    expect(page).to have_text(checklist_item.description)

    expect { click_on "Delete", match: :first }.to change(ChecklistItem, :count).by(-1)

    expect(page).to have_text("Checklist item was successfully deleted.")
    expect(page).to have_no_text(checklist_item.category)
    expect(page).to have_no_text(checklist_item.description)

    click_on "Submit"

    current_date = Time.zone.now.strftime("%m/%d/%Y")
    expect(page).to have_text("Updated #{current_date}")
  end
end
