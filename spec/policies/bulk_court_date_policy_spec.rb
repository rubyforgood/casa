require "rails_helper"

RSpec.describe BulkCourtDatePolicy, type: :policy do
  let(:casa_org) { build :casa_org }
  let(:casa_admin) { build :casa_admin, casa_org: }
  let(:volunteer) { build :volunteer, casa_org: }
  let(:supervisor) { build :supervisor, casa_org: }

  subject { described_class }

  permissions :new?, :create? do
    it "permits casa_admins" do
      is_expected.to permit(casa_admin, :bulk_court_date)
    end

    it "permits supervisor" do
      is_expected.to permit(supervisor, :bulk_court_date)
    end

    it "does not permit volunteer" do
      is_expected.to_not permit(volunteer, :bulk_court_date)
    end
  end
end
