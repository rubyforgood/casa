require "rails_helper"

RSpec.describe SupervisorPolicy do
  subject { described_class }

  let(:casa_admin) { create(:casa_admin) }
  let(:supervisor) { create(:supervisor) }
  let(:volunteer) { create(:volunteer) }

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
      let(:second_supervisor) { create(:supervisor) }

      it "does not permit the other supervisor user to update volunteer email" do
        is_expected.to_not permit(supervisor, second_supervisor)
      end

      it "does not permit the volunteer user to update volunteer email" do
        is_expected.to_not permit(volunteer, second_supervisor)
      end
    end
  end

  permissions :index? do
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

    context "when user is a volunteer" do
      it "does not have access to the supervisors index action" do
        is_expected.to_not permit(volunteer, Supervisor)
      end
    end
  end

  permissions :create? do
    it "allows admins to create supervisors" do
      is_expected.to permit(casa_admin, Supervisor)
    end

    it "does not allow supervisors to create supervisors" do
      is_expected.to_not permit(supervisor, Supervisor)
    end

    it "does not allow volunteers to create supervisors" do
      is_expected.to_not permit(volunteer, Supervisor)
    end
  end
end
