require "rails_helper"

RSpec.describe "judges/new", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org_id: organization.id) }

  before do
    sign_in admin

    visit new_judge_path
  end

  it "adds new judge" do
    fill_in "Name", with: ""
    click_on "Submit"

    expect(page).to have_text("Name can't be blank")

    fill_in "Name", with: "Joey Shmoey"
    click_on "Submit"

    expect(page).to have_text("Judge was successfully created.")
    expect(page).to have_text("Joey Shmoey")
  end
end
