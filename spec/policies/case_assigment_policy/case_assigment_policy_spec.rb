require "rails_helper"

RSpec.describe CaseAssignmentPolicy do
  subject { described_class }

  let(:organization) { create(:casa_org) }

  let(:casa_admin) { create(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let(:case_assignment) { create(:case_assignment, casa_case: casa_case, volunteer: volunteer) }
  let(:case_assignment_inactive) { create(:case_assignment, casa_case: casa_case, volunteer: volunteer, is_active: false) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }
  let(:casa_admin) { create(:casa_admin, casa_org: organization) }

  permissions :unassing? do
    it "does not allow unassign if case_assignment is inactive" do
      expect(subject).not_to permit(casa_admin, case_assignment_inactive)
    end
    context "when user is an admin" do
      it "allow update when case_assignment is active" do
        expect(subject).to permit(casa_admin, case_assignment)
      end
    end

    context "when user is a supervisor" do
      it "allow update when case_assignment is active" do
        expect(subject).to permit(supervisor, case_assignment)
      end
    end

    context "when user is a volunteer" do
      it "does not allow unassign" do
        expect(subject).not_to permit(volunteer, case_assignment)
      end
    end
  end
end
