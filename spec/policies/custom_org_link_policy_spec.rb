require "rails_helper"

RSpec.describe CustomOrgLinkPolicy, type: :policy do
  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:supervisor) { build_stubbed(:supervisor) }
  let(:volunteer) { build_stubbed(:volunteer) }

  permissions :new?, :create?, :edit?, :update? do
    it "permits casa_admins" do
      expect(described_class).to permit(casa_admin)
    end

    it "does not permit supervisor" do
      expect(described_class).not_to permit(supervisor)
    end

    it "does not permit volunteer" do
      expect(described_class).not_to permit(volunteer)
    end
  end
end
