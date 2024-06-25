require "rails_helper"

RSpec.describe StandardCourtOrderPolicy do
  subject { described_class }
  let(:standard_court_order) { build(:standard_court_order, casa_org: organization) }

  let(:organization) { build(:casa_org) }
  let(:different_organization) { create(:casa_org) }

  let(:casa_admin) { build(:casa_admin, casa_org: organization) }
  let(:other_org_casa_admin) { build(:casa_admin, casa_org: different_organization) }
  let(:volunteer) { build(:volunteer, casa_org: organization) }
  let(:other_org_volunteer) { build(:volunteer, casa_org: different_organization) }
  let(:supervisor) { build(:supervisor, casa_org: organization) }
  let(:other_org_supervisor) { build(:supervisor, casa_org: different_organization) }

  permissions :update?, :create?, :destroy?, :edit?, :new? do
    context "when part of the same organization" do
      context "an admin user" do
        it { is_expected.to permit(casa_admin, standard_court_order) }
      end

      context "a supervisor" do
        it { is_expected.to_not permit(supervisor, standard_court_order) }
      end

      context "a volunteer" do
        it { is_expected.to_not permit(volunteer, standard_court_order) }
      end
    end

    context "when not part of the same organization" do
      context "an admin user" do
        it { is_expected.to_not permit(other_org_casa_admin, standard_court_order) }
      end

      context "a supervisor" do
        it { is_expected.to_not permit(other_org_supervisor, standard_court_order) }
      end

      context "a volunteer" do
        it { is_expected.to_not permit(other_org_volunteer, standard_court_order) }
      end
    end
  end
end
