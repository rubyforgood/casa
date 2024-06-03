require "rails_helper"

RSpec.describe CaseAssignmentPolicy do
  subject { described_class }

  let(:organization) { build(:casa_org) }
  let(:casa_admin) { build(:casa_admin, casa_org: organization) }
  let(:casa_case) { build(:casa_case, casa_org: organization) }
  let(:volunteer) { build(:volunteer, casa_org: organization) }
  let(:case_assignment) { build(:case_assignment, casa_case: casa_case, volunteer: volunteer) }
  let(:case_assignment_inactive) { build(:case_assignment, casa_case: casa_case, volunteer: volunteer, active: false) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }

  let(:other_organization) { create(:casa_org) }
  let(:other_casa_case) do
    create(:casa_case, casa_org: other_organization)
  end
  let(:other_case_assignment) do
    create(:case_assignment, casa_case: other_casa_case)
  end

  permissions :create? do
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

    context "when is a different organization" do
      it "does not allow unassign" do
        is_expected.not_to permit(supervisor, other_case_assignment)
      end
    end
  end

  permissions :show_or_hide_contacts? do
    context "when an admin" do
      context "in the same organization" do
        it "allows user to show or hide contacts" do
          is_expected.to permit(casa_admin, case_assignment_inactive)
        end
      end
      context "in a different organization" do
        it "does not allow user to show or hide contacts" do
          other_case_assignment.update(active: false)
          is_expected.not_to permit(casa_admin, other_case_assignment)
        end
      end
    end

    context "when a supervisor" do
      context "in the same organization" do
        it "allows user to show or hide contacts" do
          is_expected.to permit(supervisor, case_assignment_inactive)
        end
      end
      context "in a different organization" do
        it "does not allow user to show or hide contacts" do
          other_case_assignment.update(active: false)
          is_expected.not_to permit(supervisor, other_case_assignment)
        end
      end
    end

    context "when a volunteer" do
      it "does not allow user to show or hide contacts" do
        is_expected.not_to permit(volunteer, case_assignment_inactive)
      end
    end

    context "when the case_assignment is inactive" do
      describe "it does not allow any user to show/hide contacts" do
        it { is_expected.not_to permit(casa_admin, case_assignment) }
        it { is_expected.not_to permit(supervisor, case_assignment) }
        it { is_expected.not_to permit(volunteer, case_assignment) }
      end
    end
  end

  permissions :destroy? do
    context "when user is an admin" do
      it "allow destroy" do
        is_expected.to permit(casa_admin, case_assignment)
      end
    end

    context "when user is a supervisor" do
      it "allow destroy" do
        is_expected.to permit(supervisor, case_assignment)
      end
    end

    context "when is a different organization" do
      it "does not allow admins to destroy" do
        is_expected.not_to permit(casa_admin, other_case_assignment)
      end

      it "does not allow supervisor to destroy" do
        is_expected.not_to permit(supervisor, other_case_assignment)
      end
    end
  end
end
