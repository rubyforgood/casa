require "rails_helper"

RSpec.describe ByOrganizationScope, type: :model do
  describe ".by_organization" do
    let(:casa_org) { create(:casa_org) }
    let(:other_casa_org) { create(:casa_org) }

    let!(:casa_case_in_org) { create(:casa_case, casa_org: casa_org) }
    let!(:casa_case_in_other_org) { create(:casa_case, casa_org: other_casa_org) }

    it "returns only the records belonging to the given organization" do
      expect(CasaCase.by_organization(casa_org)).to contain_exactly(casa_case_in_org)
    end

    it "returns no records for an organization without records" do
      empty_casa_org = create(:casa_org)

      expect(CasaCase.by_organization(empty_casa_org)).to be_empty
    end
  end
end
