require "rails_helper"

RSpec.describe "checklist_items/destroy" do
  let(:casa_org) { create(:casa_org) }
  let(:casa_admin) { create(:casa_admin, casa_org:) }
  let(:hearing_type) { create(:hearing_type, casa_org:) }
  let!(:checklist_item) { create(:checklist_item, hearing_type:) }

  before do
    sign_in casa_admin
  end

  it "deletes checklist items" do
    visit edit_hearing_type_path(hearing_type)
    expect(page).to have_text(checklist_item.category)
    expect(page).to have_text(checklist_item.description)

    click_on "Delete", match: :first

    expect(page).to have_text("Checklist item was successfully deleted.")
    expect(page).to have_no_text(checklist_item.category)
    expect(page).to have_no_text(checklist_item.description)

    click_on "Submit"

    current_date = Date.current.strftime("%m/%d/%Y")
    expect(page).to have_text("Updated #{current_date}")
    expect {
      checklist_item.reload
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
