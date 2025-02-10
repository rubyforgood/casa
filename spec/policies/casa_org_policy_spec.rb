require "rails_helper"

RSpec.describe CasaOrgPolicy do
  subject { described_class }

  let(:organization) { build(:casa_org, users: [volunteer, supervisor, casa_admin]) }
  let(:different_organization) { create(:casa_org) }

  let(:volunteer) { build(:volunteer) }
  let(:supervisor) { build(:supervisor) }
  let(:casa_admin) { build(:casa_admin) }

  permissions :edit?, :update? do
    context "when admin belongs to the same org" do
      it "allows casa_admins" do
        expect(subject).to permit(casa_admin, organization)
      end
    end

    context "when admin does not belong to org" do
      it "does not permit admin" do
        expect(subject).not_to permit(casa_admin, different_organization)
      end
    end

    it "does not permit supervisor" do
      expect(subject).not_to permit(supervisor, organization)
    end

    it "does not permit volunteer" do
      expect(subject).not_to permit(volunteer, organization)
    end
  end
end
