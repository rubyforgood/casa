require "rails_helper"

RSpec.describe CaseAssignmentPolicy do
  subject { described_class }

  let(:organization) { build(:casa_org) }

  let(:casa_admin) { build(:casa_admin, casa_org: organization) }
  let(:casa_case) { build(:casa_case, casa_org: organization) }
  let(:volunteer) { build(:volunteer, casa_org: organization) }
  let(:case_assignment) { build(:case_assignment, casa_case: casa_case, volunteer: volunteer) }
  let(:case_assignment_inactive) { build(:case_assignment, casa_case: casa_case, volunteer: volunteer, active: false) }
  let(:supervisor) { build(:supervisor, casa_org: organization) }
  let(:casa_admin) { build(:casa_admin, casa_org: organization) }

  permissions :create?, :destroy? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    it "allows supervisor" do
      is_expected.to permit(supervisor)
    end

    it "does not permit volunteer" do
      is_expected.to_not permit(volunteer)
    end
  end

  permissions :unassign? do
    it "does not allow unassign if case_assignment is inactive" do
      is_expected.not_to permit(casa_admin, case_assignment_inactive)
    end

    context "when user is an admin" do
      it "allow update when case_assignment is active" do
        is_expected.to permit(casa_admin, case_assignment)
      end
    end

    context "when user is a supervisor" do
      it "allow update when case_assignment is active" do
        is_expected.to permit(supervisor, case_assignment)
      end
    end

    context "when user is a volunteer" do
      it "does not allow unassign" do
        is_expected.not_to permit(volunteer, case_assignment)
      end
    end
  end
end
