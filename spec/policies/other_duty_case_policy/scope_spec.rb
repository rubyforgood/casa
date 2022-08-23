require "rails_helper"

RSpec.describe OtherDutyPolicy::Scope do
  describe "#resolve" do
    let(:volunteer) { create(:volunteer) }
    let!(:other_duty) { create(:other_duty, creator: volunteer) }
    let(:org_admin) { create(:casa_admin, casa_org_id: volunteer.casa_org_id) }

    it "returns volunteers in the same org as the admin" do
      scope = described_class.new(org_admin, Volunteer)

      expect(scope.resolve).to eq(Volunteer.where(casa_org_id: org_admin.casa_org_id))
    end
  end
end
