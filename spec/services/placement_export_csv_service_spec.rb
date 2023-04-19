require "rails_helper"
require "factory_bot_rails"

RSpec.describe PlacementExportCsvService do
  let(:casa_org) { create(:casa_org, name: "Fake Name", display_name: "Fake Display Name") }
  let(:placement_type) { build(:placement_type, casa_org: casa_org) }
  let(:creator) { build(:user) }
  let(:placement) { build(:placement, creator: creator, placement_type: placement_type) }

  it "creates a Placements csv with placements headers" do
    csv_headers = "Casa Org,Casa Case Number,Placement Type,Placement Started At,Created At,Creator Name\n"
    placements = Placement.all
    result = PlacementExportCsvService.new(casa_org_id: casa_org.id).perform
    expect(result).to start_with(csv_headers)
  end
end
