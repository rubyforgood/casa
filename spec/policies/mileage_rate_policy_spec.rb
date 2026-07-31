require "rails_helper"

RSpec.describe MileageRatePolicy, type: :policy do
  subject { described_class }

  let(:organization) { build_stubbed(:casa_org) }
  let(:other_organization) { build_stubbed(:casa_org) }
  let(:mileage_rate) { build_stubbed(:mileage_rate, casa_org: organization) }

  let(:casa_admin) { build_stubbed(:casa_admin, casa_org: organization) }
  let(:other_org_admin) { build_stubbed(:casa_admin, casa_org: other_organization) }
  let(:supervisor) { build_stubbed(:supervisor, casa_org: organization) }
  let(:volunteer) { build_stubbed(:volunteer, casa_org: organization) }

  # Every action is is_admin_same_org?, so the org half matters as much as the role half: the
  # controller previously called `authorize CasaAdmin` with the CLASS, which skipped the org check
  # entirely and let an admin edit another chapter's rate.
  permissions :new?, :create?, :edit?, :update? do
    it "permits an admin in the rate's own organization" do
      expect(subject).to permit(casa_admin, mileage_rate)
    end

    it "does not permit an admin from another organization" do
      expect(subject).not_to permit(other_org_admin, mileage_rate)
    end

    it "does not permit supervisors" do
      expect(subject).not_to permit(supervisor, mileage_rate)
    end

    it "does not permit volunteers" do
      expect(subject).not_to permit(volunteer, mileage_rate)
    end

    it "does not permit a nil user" do
      expect(subject).not_to permit(nil, mileage_rate)
    end
  end
end
