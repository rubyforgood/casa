require "rails_helper"

RSpec.describe CasaCasePolicy::Scope do
  describe "#resolve" do
    it "returns all CasaCases when user is admin" do
      user = create(:casa_admin)
      all_casa_cases = create_list(:casa_case, 2)

      scope = described_class.new(user, CasaCase)

      expect(scope.resolve).to contain_exactly(*all_casa_cases)
    end

    it "returns active cases of the volunteer when user is volunteer" do
      user = create(:volunteer)
      create_list(:casa_case, 2)
      casa_cases = create_list(:casa_case, 2, volunteers: [user])

      scope = described_class.new(user, CasaCase)

      expect(scope.resolve).to eq casa_cases
    end
  end
end
