require "rails_helper"

RSpec.describe SupervisorPolicy do
  subject { described_class }

  let(:organization) { create(:casa_org) }
  let(:different_organization) { create(:casa_org) }

  let!(:casa_admin) { create(:casa_admin, casa_org: organization) }
  let!(:supervisor) { create(:supervisor, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }

  permissions :update_supervisor_email? do
    context "when user is an admin or is the record" do
      it "permits an admin to update supervisor email" do
        is_expected.to permit(casa_admin, supervisor)
      end

      it "permits the supervisor to update their own email" do
        is_expected.to permit(supervisor, supervisor)
      end
    end

    context "when user is not an admin or the record" do
      let(:second_supervisor) { build_stubbed(:supervisor) }

      it "does not permit the other supervisor user to update volunteer email" do
        is_expected.to_not permit(supervisor, second_supervisor)
      end

      it "does not permit the volunteer user to update volunteer email" do
        is_expected.to_not permit(volunteer, second_supervisor)
      end
    end
  end

  permissions :update? do
    context "same organization" do
      it "allows casa_admins" do
        is_expected.to permit(casa_admin, supervisor)
      end
    end

    context "different organization" do
      let(:other_admin) { create(:casa_admin, casa_org: different_organization) }
      it "does not allow casa_admins" do
        is_expected.to_not permit(other_admin, supervisor)
      end
    end

    it "allows supervisors to update themselves" do
      is_expected.to permit(supervisor, supervisor)
    end

    it "does not allow supervisors to update other supervisors" do
      another_supervisor = build_stubbed(:supervisor)

      is_expected.not_to permit(supervisor, another_supervisor)
    end
  end

  permissions :edit? do
    context "same org" do
      let(:record) { build_stubbed(:supervisor, casa_org: casa_admin.casa_org) }
      context "when user is admin" do
        it "can edit a supervisor" do
          is_expected.to permit(casa_admin, record)
        end
      end
      context "when user is supervisor" do
        it "can edit a supervisor" do
          is_expected.to permit(supervisor, record)
        end
      end
    end
    context "different org" do
      let(:record) { build_stubbed(:supervisor, casa_org: different_organization) }
      context "when user is admin" do
        it "cannot edit a supervisor" do
          is_expected.not_to permit(casa_admin, record)
        end
      end
      context "when user is a supervisor" do
        it "cannot edit a supervisor" do
          is_expected.not_to permit(supervisor, record)
        end
      end
    end
  end

  permissions :index?, :datatable? do
    context "when user is an admin" do
      it "has access to the supervisors index action" do
        is_expected.to permit(casa_admin, Supervisor)
      end
    end

    context "when user is a supervisor" do
      it "has access to the supervisors index action" do
        is_expected.to permit(supervisor, Supervisor)
      end
    end
  end

  permissions :index?, :edit?, :datatable? do
    context "when user is a volunteer" do
      it "does not have access to the supervisors index action" do
        is_expected.to_not permit(volunteer, Supervisor)
      end
    end
  end

  permissions :create?, :new? do
    it "allows admins to modify supervisors" do
      is_expected.to permit(casa_admin, Supervisor)
    end

    it "does not allow supervisors to modify supervisors" do
      is_expected.to_not permit(supervisor, Supervisor)
    end

    it "does not allow volunteers to modify supervisors" do
      is_expected.to_not permit(volunteer, Supervisor)
    end
  end

  permissions :resend_invitation?, :activate?, :deactivate? do
    context "same organization" do
      it "allows admins to modify supervisors" do
        is_expected.to permit(casa_admin, supervisor)
      end
    end

    context "different organization" do
      let(:other_admin) { create(:casa_admin, casa_org: different_organization) }
      it "does not allow admin to modify supervisors" do
        is_expected.to_not permit(other_admin, supervisor)
      end
    end

    it "does not allow supervisors to modify supervisors" do
      is_expected.to_not permit(supervisor, supervisor)
    end

    it "does not allow volunteers to modify supervisors" do
      is_expected.to_not permit(volunteer, supervisor)
    end
  end

  permissions :change_to_admin? do
    it "allows admins to change to admin" do
      is_expected.to permit(casa_admin, supervisor)
    end

    it "does not allow supervisors to change to admin" do
      is_expected.to_not permit(supervisor, Supervisor)
    end

    it "does not allow volunteers to change to admin" do
      is_expected.to_not permit(volunteer, Supervisor)
    end
  end
end
