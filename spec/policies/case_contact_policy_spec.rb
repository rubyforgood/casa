require "rails_helper"

RSpec.describe CaseContactPolicy, aggregate_failures: true do
  subject { described_class }

  let(:casa_org) { create(:casa_org) }
  let(:casa_admin) { build(:casa_admin, casa_org:) }
  let(:supervisor) { build(:supervisor, casa_org:) }
  let(:volunteer) { create(:volunteer, :with_single_case, supervisor:, casa_org:) }
  let(:casa_case) { volunteer.casa_cases.first }

  let(:case_contact) { create(:case_contact, casa_case:, creator: volunteer, casa_org:) }
  let(:draft_case_contact) { create(:case_contact, :started_status, casa_case: nil, creator: volunteer) }

  # another volunteer assigned to the same case
  let(:same_case_volunteer) { create :volunteer, casa_org: }
  let(:same_case_volunteer_case_assignment) { create :case_assignment, volunteer: same_case_volunteer, casa_case: }
  let(:same_case_volunteer_case_contact) do
    same_case_volunteer_case_assignment
    create :case_contact, casa_case:, creator: same_case_volunteer
  end

  # same org case that volunteer is not assigned to
  let(:unassigned_case_case_contact) do
    create :case_contact, casa_case: create(:casa_case, casa_org:), creator: create(:volunteer, casa_org:)
  end
  let(:other_org_case_contact) { build(:case_contact, casa_org: create(:casa_org)) }

  permissions :index? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    it "allows supervisor" do
      is_expected.to permit(supervisor)
    end

    it "allows volunteer" do
      is_expected.to permit(volunteer)
    end
  end

  permissions :show? do
    it "allows same org casa_admins" do
      is_expected.to permit(casa_admin, case_contact)
      is_expected.to permit(casa_admin, draft_case_contact)
      is_expected.to permit(casa_admin, same_case_volunteer_case_contact)
      is_expected.to permit(casa_admin, unassigned_case_case_contact)

      is_expected.not_to permit(casa_admin, other_org_case_contact)
    end

    it "does not allow supervisors" do
      is_expected.not_to permit(supervisor, case_contact)
      is_expected.not_to permit(supervisor, draft_case_contact)
      is_expected.not_to permit(supervisor, same_case_volunteer_case_contact)
      is_expected.not_to permit(casa_admin, unassigned_case_case_contact)
      is_expected.not_to permit(supervisor, other_org_case_contact)

      pending "allow supervisors of the case creator volunteer?"
      # are they supervisors of volunteer, or of the case? both?
      is_expected.to permit(supervisor, case_contact)
      is_expected.to permit(supervisor, draft_case_contact)
    end

    it "allows volunteer only if they created the case contact" do
      is_expected.to permit(volunteer, case_contact)
      is_expected.to permit(volunteer, draft_case_contact)

      is_expected.not_to permit(volunteer, unassigned_case_case_contact)
      is_expected.not_to permit(volunteer, other_org_case_contact)

      pending "should volunteers be able to view contacts from other volunteer for same case?"
      is_expected.to permit(volunteer, same_case_volunteer_case_contact)
    end
  end

  permissions :edit?, :update? do
    it "allows same org casa_admins" do
      is_expected.to permit(casa_admin, case_contact)
      is_expected.to permit(casa_admin, draft_case_contact)
      is_expected.to permit(casa_admin, same_case_volunteer_case_contact)
      is_expected.to permit(casa_admin, unassigned_case_case_contact)

      is_expected.not_to permit(casa_admin, other_org_case_contact)
    end

    it "allows same org supervisors" do
      is_expected.to permit(supervisor, case_contact)
      is_expected.to permit(supervisor, draft_case_contact)
      is_expected.to permit(supervisor, same_case_volunteer_case_contact)

      is_expected.not_to permit(supervisor, other_org_case_contact)

      pending "restrict supervisors who are not assigned to the volunteer/case?"
      is_expected.not_to permit(supervisor, unassigned_case_case_contact)
    end

    it "allows volunteer only if they created the case contact" do
      is_expected.to permit(volunteer, case_contact)
      is_expected.to permit(volunteer, draft_case_contact)

      is_expected.not_to permit(volunteer, same_case_volunteer_case_contact)
      is_expected.not_to permit(volunteer, unassigned_case_case_contact)
      is_expected.not_to permit(volunteer, other_org_case_contact)
    end
  end

  permissions :new? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin, CaseContact.new)
    end

    it "allows supervisors" do
      is_expected.to permit(supervisor, CaseContact.new)
    end

    it "allows volunteers" do
      is_expected.to permit(volunteer, CaseContact.new)
      is_expected.to permit(volunteer, case_contact)
      is_expected.to permit(volunteer, draft_case_contact)

      pending "require volunteer to be the contact creator?"
      is_expected.not_to permit(volunteer, CaseContact.new)
    end
  end

  permissions :drafts? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    it "allows supervisors" do
      is_expected.to permit(supervisor)
    end

    it "does not allow volunteers" do
      is_expected.not_to permit(volunteer)
    end
  end

  permissions :destroy? do
    it "allows same org casa_admins" do
      is_expected.to permit(casa_admin, case_contact)
      is_expected.to permit(casa_admin, draft_case_contact)
      is_expected.to permit(casa_admin, same_case_volunteer_case_contact)
      is_expected.to permit(casa_admin, unassigned_case_case_contact)

      is_expected.not_to permit(casa_admin, other_org_case_contact)
    end

    it "allows supervisors" do
      is_expected.to permit(supervisor, case_contact)
      is_expected.to permit(supervisor, draft_case_contact)
      is_expected.to permit(supervisor, same_case_volunteer_case_contact)

      is_expected.not_to permit(supervisor, other_org_case_contact)

      pending "resctrict supervisors to their volunteers/cases?"
      is_expected.not_to permit(supervisor, unassigned_case_case_contact)
    end

    it "allows volunteer only for draft contacts they created" do
      is_expected.to permit(volunteer, draft_case_contact)

      is_expected.not_to permit(volunteer, case_contact)
      is_expected.not_to permit(volunteer, same_case_volunteer_case_contact)
      is_expected.not_to permit(volunteer, unassigned_case_case_contact)
      is_expected.not_to permit(volunteer, other_org_case_contact)
    end
  end

  permissions :restore? do
    it "allows same org casa_admins" do
      is_expected.to permit(casa_admin, case_contact)
      is_expected.to permit(casa_admin, draft_case_contact)
      is_expected.to permit(casa_admin, same_case_volunteer_case_contact)
      is_expected.to permit(casa_admin, unassigned_case_case_contact)
      is_expected.not_to permit(casa_admin, other_org_case_contact)
    end

    it "does not allow supervisors" do
      is_expected.not_to permit(supervisor, case_contact)
      is_expected.not_to permit(supervisor, draft_case_contact)
      is_expected.not_to permit(supervisor, same_case_volunteer_case_contact)
      is_expected.not_to permit(supervisor, unassigned_case_case_contact)
      is_expected.not_to permit(supervisor, other_org_case_contact)
    end

    it "does not allow volunteers" do
      is_expected.not_to permit(volunteer, draft_case_contact)
      is_expected.not_to permit(volunteer, case_contact)
      is_expected.not_to permit(volunteer, same_case_volunteer_case_contact)
      is_expected.not_to permit(volunteer, unassigned_case_case_contact)
      is_expected.not_to permit(volunteer, other_org_case_contact)
    end
  end

  describe "Scope#resolve" do
    subject { described_class::Scope.new(user, CaseContact.all).resolve }

    before do
      case_contact
      draft_case_contact
      same_case_volunteer_case_contact
      unassigned_case_case_contact
      other_org_case_contact
    end

    context "when user is a visitor" do
      let(:user) { nil }

      it "returns no case contacts" do
        is_expected.not_to include(case_contact, other_org_case_contact)
      end
    end

    context "when user is a volunteer" do
      let(:user) { volunteer }

      it "returns case contacts created by the volunteer" do
        is_expected.to include(case_contact, draft_case_contact)
        is_expected
          .not_to include(same_case_volunteer_case_contact, unassigned_case_case_contact, other_org_case_contact)
      end
    end

    context "when user is a supervisor" do
      let(:user) { supervisor }

      it "returns same org case contacts" do
        is_expected
          .to include(case_contact, draft_case_contact, same_case_volunteer_case_contact, unassigned_case_case_contact)
        is_expected.not_to include(other_org_case_contact)

        pending "should supervisors see contacts for volunteers they are not assigned to?"
        is_expected.not_to include(unassigned_case_case_contact)
      end
    end

    context "when user is a casa_admin" do
      let(:user) { casa_admin }

      it "returns same org case contacts" do
        is_expected
          .to include(case_contact, draft_case_contact, same_case_volunteer_case_contact, unassigned_case_case_contact)
        is_expected.not_to include(other_org_case_contact)
      end
    end

    context "when user is an all_casa_admin" do
      let(:user) { create :all_casa_admin }

      it "returns no case contacts" do
        is_expected.not_to include(case_contact, other_org_case_contact)
      end
    end
  end
end
