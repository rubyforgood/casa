require "rails_helper"

RSpec.describe CasaCasePolicy::Scope do
  let(:organization) { create(:casa_org) }

  describe "#resolve" do
    it "returns all CasaCases when user is admin" do
      user = create(:casa_admin, casa_org: organization)
      all_casa_cases = create_list(:casa_case, 2, casa_org: organization)
      other_casa_cases = create_list(:casa_case, 2)

      scope = described_class.new(user, organization.casa_cases)

      expect(scope.resolve).to contain_exactly(*all_casa_cases)
    end

    it "returns active cases of the volunteer when user is volunteer" do
      user = create(:volunteer, casa_org: organization)
      casa_cases = create_list(:casa_case, 2, volunteers: [user], casa_org: organization)

      more_user = create(:volunteer, casa_org: organization)
      more_casa_cases = create_list(:casa_case, 2, volunteers: [more_user], casa_org: organization)

      other_org = create(:casa_org)
      other_user = create(:volunteer, casa_org: other_org)
      other_casa_cases = create_list(:casa_case, 2, volunteers: [other_user], casa_org: other_org)

      scope = described_class.new(user, organization.casa_cases)

      expect(CasaCase.count).to eq 6
      expect(scope.resolve.count).to eq 2
      expect(scope.resolve).to eq casa_cases
    end
  end
end
