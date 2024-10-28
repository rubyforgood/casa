# frozen_string_literal: true

require "rails_helper"

RSpec.describe "placements/edit" do
  let(:date_format) { "%B %-d, %Y" }
  let(:casa_org) { create(:casa_org, :with_placement_types) }
  let(:admin) { create(:casa_admin, casa_org:) }
  let(:casa_case) { create(:casa_case, casa_org:, case_number: "123") }
  let(:placement_type) { create(:placement_type, name: "Reunification", casa_org:) }
  let(:placement) { create(:placement, placement_started_at: "2024-08-15 20:40:44 UTC", casa_case:, placement_type:) }

  before do
    sign_in admin
    visit casa_case_placement_path(casa_case, placement)
    click_on "Edit"
  end

  it "updates placement with valid form data", :js do
    expect(page).to have_content("123")

    started_at = Date.current - 5.years
    fill_in "Placement Started At", with: started_at
    select "Kinship", from: "Placement Type"

    click_on "Update"

    expect(page).to have_content("Placement was successfully updated.")
    expect(page).to have_content("123")
    expect(page).to have_content(started_at.strftime(date_format))
    expect(page).to have_content("Kinship")
  end

  it "rejects placement update with invalid form data" do
    fill_in "Placement Started At", with: 1000.years.ago
    click_on "Update"

    expect(page).to have_content("1 error prohibited this Placement from being saved:\nPlacement started at cannot be prior to 1/1/1989.")
  end
end
