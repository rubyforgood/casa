require "rails_helper"

RSpec.describe "learning_hours/edit", type: :system do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org_id: organization.id) }
  let(:learning_hours) { create(:learning_hour, user: volunteer) }

  before do
    sign_in volunteer

    visit edit_learning_hour_path(learning_hours)
  end

  it "shows error message when future date entered" do
    datepicker_input = find("#learning_hour_occurred_at")
    datepicker_input.set((Date.today + 1.month).strftime("%Y-%m-%d"))

    click_on "Update Learning Hours Entry"

    expect(page).to have_text("Date cannot be in the future")
  end

  it "can update learning hours entry with proper data" do
    title = "Updated Title"

    expect(page).to have_field("Learning Hours Title", with: learning_hours.name)

    fill_in "Learning Hours Title",	with: title
    click_on "Update Learning Hours Entry"

    expect(page).to have_text("Entry was successfully updated.")
    expect(page).to have_text(title)
  end
end
