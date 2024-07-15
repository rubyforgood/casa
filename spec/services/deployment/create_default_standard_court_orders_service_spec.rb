require "rails_helper"

RSpec.describe Deployment::CreateDefaultStandardCourtOrdersService do
  describe "#create_defaults" do
    let!(:casa_org_1) { create(:casa_org) }
    let!(:casa_org_2) { create(:casa_org) }

    it "creates StandardCourtOrders from DEFAULT_STANDARD_COURT_ORDERS for each org" do
      stub_const("Deployment::CreateDefaultStandardCourtOrdersService::DEFAULT_STANDARD_COURT_ORDERS",
        ["Default 1", "Default 2"])

      described_class.new.create_defaults

      expect(StandardCourtOrder.count).to eq(4)
      expect(casa_org_1.standard_court_orders.map(&:value)).to eq(["Default 1", "Default 2"])
      expect(casa_org_2.standard_court_orders.map(&:value)).to eq(["Default 1", "Default 2"])
    end
  end
end
