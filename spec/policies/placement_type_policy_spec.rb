require "rails_helper"

RSpec.describe PlacementTypePolicy, type: :policy do
  let(:casa_org) { create :casa_org }
  let(:volunteer) { create :volunteer, casa_org: }
  let(:supervisor) { create :supervisor, casa_org: }
  let(:casa_admin) { create :casa_admin, casa_org: }
  let(:all_casa_admin) { create :all_casa_admin }

  let(:placement_type) { create :placement_type, casa_org: }

  subject { described_class }

  permissions :edit?, :new?, :update?, :create? do
    it "does not permit a nil user" do
      expect(described_class).not_to permit(nil, placement_type)
    end

    it "does not permit a volunteer" do
      expect(described_class).not_to permit(volunteer, placement_type)
    end

    it "does not permit a supervisor" do
      expect(described_class).not_to permit(supervisor, placement_type)
    end

    it "permits a casa admin" do
      expect(described_class).to permit(casa_admin, placement_type)
    end

    it "does not permit a casa admin for a different casa org" do
      other_org_casa_admin = create :casa_admin, casa_org: create(:casa_org)
      expect(described_class).not_to permit(other_org_casa_admin, placement_type)
    end

    it "does not permit an all casa admin" do
      expect(described_class).not_to permit(all_casa_admin, placement_type)
    end
  end
end
