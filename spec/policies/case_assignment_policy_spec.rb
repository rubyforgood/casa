require "rails_helper"

RSpec.describe CaseAssignmentPolicy do
  subject { described_class }

  let(:organization) { create(:casa_org) }
  let(:casa_admin) { build(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:volunteer) { build(:volunteer, casa_org: organization) }
  let(:case_assignment) { build(:case_assignment, casa_case: casa_case, volunteer: volunteer) }
  let(:case_assignment_inactive) { build(:case_assignment, casa_case: casa_case, volunteer: volunteer, active: false) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }

  let(:other_organization) { create(:casa_org) }
  let(:other_casa_case) do
    create(:casa_case, casa_org: other_organization)
  end
  let(:other_case_assignment) do
    build(:case_assignment, casa_case: other_casa_case)
  end

  permissions :create? do
    it "allows casa_admins and supervisors" do
      expect(subject).to permit(casa_admin)
      expect(subject).to permit(supervisor)
      expect(subject).not_to permit(volunteer)
    end
  end

  permissions :unassign? do
    it "allows org casa_admins and supervisors if case_assignment is active" do
      expect(subject).to permit(casa_admin, case_assignment)
      expect(subject).to permit(supervisor, case_assignment)
      expect(subject).not_to permit(volunteer, case_assignment)

      expect(subject).not_to permit(casa_admin, case_assignment_inactive)
      expect(subject).not_to permit(supervisor, case_assignment_inactive)
      expect(subject).not_to permit(volunteer, case_assignment_inactive)

      expect(subject).not_to permit(supervisor, other_case_assignment)
      expect(subject).not_to permit(casa_admin, other_case_assignment)
      expect(subject).not_to permit(volunteer, other_case_assignment)
    end
  end

  permissions :show_or_hide_contacts? do
    let(:other_case_assignment) { build_stubbed(:case_assignment, casa_case: other_casa_case, active: false) }

    it "allows org admins and supervisors only if case assignment.active is false" do
      expect(subject).not_to permit(casa_admin, case_assignment)
      expect(subject).not_to permit(supervisor, case_assignment)
      expect(subject).not_to permit(volunteer, case_assignment)

      expect(subject).to permit(casa_admin, case_assignment_inactive)
      expect(subject).to permit(supervisor, case_assignment_inactive)
      expect(subject).not_to permit(volunteer, case_assignment_inactive)

      expect(subject).not_to permit(supervisor, other_case_assignment)
      expect(subject).not_to permit(casa_admin, other_case_assignment)
      expect(subject).not_to permit(volunteer, other_case_assignment)
    end
  end

  permissions :destroy? do
    it "allows org casa_admins and supervisors" do
      expect(subject).to permit(casa_admin, case_assignment)
      expect(subject).to permit(supervisor, case_assignment)
      expect(subject).not_to permit(volunteer, case_assignment)

      expect(subject).not_to permit(casa_admin, other_case_assignment)
      expect(subject).not_to permit(supervisor, other_case_assignment)
      expect(subject).not_to permit(volunteer, other_case_assignment)
    end
  end
end
