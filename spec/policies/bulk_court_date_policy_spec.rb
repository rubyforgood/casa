require "rails_helper"

RSpec.describe BulkCourtDatePolicy, type: :policy do
  subject { described_class }

  let(:casa_org) { build :casa_org }
  let(:casa_admin) { build :casa_admin, casa_org: }
  let(:volunteer) { build :volunteer, casa_org: }
  let(:supervisor) { build :supervisor, casa_org: }

  permissions :new?, :create? do
    it "permits casa_admins" do
      expect(subject).to permit(casa_admin, :bulk_court_date)
    end

    it "permits supervisor" do
      expect(subject).to permit(supervisor, :bulk_court_date)
    end

    it "does not permit volunteer" do
      expect(subject).not_to permit(volunteer, :bulk_court_date)
    end
  end
end
