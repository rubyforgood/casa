require "rails_helper"

RSpec.describe AllCasaAdmins::CasaOrgsHelper, type: :helper do
  describe "#selected_organization" do
    it "returns the assigned @casa_org" do
      casa_org = build(:casa_org)
      assign(:casa_org, casa_org)

      expect(helper.selected_organization).to eq(casa_org)
    end

    it "returns nil when no @casa_org is assigned" do
      expect(helper.selected_organization).to be_nil
    end
  end
end
