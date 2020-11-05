require "rails_helper"

RSpec.describe CasaAdminPolicy do
  subject { described_class }

  let(:organization) { create(:casa_org) }
  let(:casa_admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }

  permissions :index? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    it "allows supervisor" do
      is_expected.to_not permit(supervisor)
    end

    it "allows supervisor" do
      is_expected.to_not permit(volunteer)
    end
  end

  permissions :deactivate? do
    context "when user is a casa admin" do
      let(:admin_inactive) { create(:casa_admin, active: false, casa_org: organization) }

      it "does permit if is a inactive user" do
        is_expected.not_to permit(admin_inactive, :casa_admin)
      end

      it "does permit if is the only admin" do
        is_expected.not_to permit(casa_admin, :casa_admin)
      end

      it "permit if is a active user and exist other casa admins" do
        create(:casa_admin, casa_org: organization)
        is_expected.to permit(casa_admin, :casa_admin)
      end
    end

    context "when user is a supervisor" do
      it "does not permit" do
        is_expected.not_to permit(supervisor, :casa_admin)
      end
    end

    context "when user is a volunteer" do
      it "does not permit" do
        is_expected.not_to permit(volunteer)
      end
    end
  end
end
