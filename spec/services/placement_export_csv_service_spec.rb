require "rails_helper"
require "factory_bot_rails"

RSpec.describe PlacementExportCsvService do
  it "creates a Placements CSV with placement headers" do
    casa_org = create(:casa_org, name: "Fake Name", display_name: "Fake Display Name")
    placement_type = create(:placement_type, casa_org: casa_org)
    creator = create(:user)
    placement = create(:placement, creator: creator, placement_type: placement_type) # rubocop:disable Lint/UselessAssignment

    csv_headers = "Casa Org,Casa Case Number,Placement Type,Placement Started At,Created At,Creator Name\n"
    result = PlacementExportCsvService.new(casa_org: casa_org).perform
    expect(result).to start_with(csv_headers)
  end
end
