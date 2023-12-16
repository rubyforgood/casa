require "rails_helper"

RSpec.describe "learning_hours/new", type: :system, js: true do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org_id: organization.id) }

  before do
    create(:learning_hour_type, casa_org: organization, name: "Book")

    sign_in volunteer

    visit new_volunteer_learning_hour_path(volunteer)
  end

  it "errors without selected type of learning" do
    fill_in "Learning Hours Title",	with: "Test title"
    fill_in "Hour(s)", with: "0"
    fill_in "Minute(s)", with: "30"
    click_on "Create New Learning Hours Entry"

    expect(page).to have_text("Type of Learning must exist")
  end

  it "creates learning hours entry with valid data" do
    fill_in "Learning Hours Title",	with: "Test title"
    select "Book", from: "Type of Learning"
    fill_in "Hour(s)", with: "0"
    fill_in "Minute(s)", with: "30"
    click_on "Create New Learning Hours Entry"

    expect(page).to have_text("New entry was successfully created.")
  end
end
