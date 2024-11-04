# frozen_string_literal: true

require "rails_helper"

RSpec.describe "placements/new" do
  let(:date_format) { "%B %-d, %Y" }
  let(:casa_org) { create(:casa_org, :with_placement_types) }
  let(:admin) { create(:casa_admin, casa_org:) }
  let(:casa_case) { create(:casa_case, casa_org:, case_number: "123") }
  let(:placement_type) { create(:placement_type, name: "Reunification", casa_org:) }
  let(:placement) { create(:placement, placement_started_at: "2024-08-15 20:40:44 UTC", casa_case:, placement_type:) }

  before do
    sign_in admin
    visit casa_case_placements_path(casa_case)
    click_on "New Placement"
  end

  it "creates placement with valid form data", :js do
    expect(page).to have_content("123")

    started_at = Date.current
    fill_in "Placement Started At", with: started_at
    select placement_type.name, from: "Placement Type"

    click_on "Create"

    expect(page).to have_content("Placement was successfully created.")
    expect(page).to have_content("123")
    expect(page).to have_content(started_at.strftime(date_format))
    expect(page).to have_content("Reunification")
  end

  it "rejects placement with invalid form data" do
    fill_in "Placement Started At", with: 1000.years.ago
    click_on "Create"

    expect(page).to have_content("2 errors prohibited this Placement from being saved:\nPlacement type must exist Placement started at cannot be prior to 1/1/1989.")
  end
end
