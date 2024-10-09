require "rails_helper"

RSpec.describe CaseContactPolicy, aggregate_failures: true do
  subject { described_class }

  let(:casa_org) { create(:casa_org) }
  let(:casa_admin) { build(:casa_admin, casa_org:) }
  let(:supervisor) { build(:supervisor, casa_org:) }
  let(:volunteer) { build(:volunteer, supervisor:, casa_org:) }

  let(:case_contact) { build(:case_contact, creator: volunteer, casa_org:) }
  let(:draft_case_contact) { build(:case_contact, :started_status, creator: volunteer, casa_org:) }
  let(:other_volunteer_case_contact) { build(:case_contact, creator: create(:volunteer, casa_org:)) }
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
      is_expected.to permit(casa_admin, other_volunteer_case_contact)
      is_expected.not_to permit(casa_admin, other_org_case_contact)
    end

    it "does not allow supervisors" do
      is_expected.not_to permit(supervisor, case_contact)
      is_expected.not_to permit(supervisor, draft_case_contact)
      is_expected.not_to permit(supervisor, other_volunteer_case_contact)
      is_expected.not_to permit(supervisor, other_org_case_contact)
      pending "allow supervisors of the case creator volunteer?"
      is_expected.to permit(supervisor, case_contact)
      is_expected.to permit(supervisor, draft_case_contact)
    end

    it "allows volunteer only if they created the case contact" do
      is_expected.to permit(volunteer, case_contact)
      is_expected.to permit(volunteer, draft_case_contact)
      is_expected.not_to permit(volunteer, other_volunteer_case_contact)
      is_expected.not_to permit(volunteer, other_org_case_contact)
    end
  end

  permissions :edit?, :update? do
    it "allows same org casa_admins" do
      is_expected.to permit(casa_admin, case_contact)
      is_expected.to permit(casa_admin, draft_case_contact)
      is_expected.to permit(casa_admin, other_volunteer_case_contact)
      is_expected.not_to permit(casa_admin, other_org_case_contact)
    end

    it "allows same org supervisors" do
      is_expected.to permit(supervisor, case_contact)
      is_expected.to permit(supervisor, draft_case_contact)
      is_expected.to permit(supervisor, other_volunteer_case_contact)
      is_expected.not_to permit(supervisor, other_org_case_contact)
    end

    it "allows volunteer only if they created the case contact" do
      is_expected.to permit(volunteer, case_contact)
      is_expected.to permit(volunteer, draft_case_contact)
      is_expected.not_to permit(volunteer, other_volunteer_case_contact)
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

    it "does allow volunteers" do
      is_expected.to permit(volunteer, CaseContact.new)
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
      is_expected.to permit(casa_admin, other_volunteer_case_contact)
      is_expected.not_to permit(casa_admin, other_org_case_contact)
    end

    it "allows supervisors" do
      is_expected.to permit(supervisor, case_contact)
      is_expected.to permit(supervisor, draft_case_contact)
      is_expected.to permit(supervisor, other_volunteer_case_contact)
      is_expected.not_to permit(supervisor, other_org_case_contact)
    end

    it "allows volunteer only for draft contacts they created" do
      is_expected.to permit(volunteer, draft_case_contact)
      is_expected.not_to permit(volunteer, case_contact)
      is_expected.not_to permit(volunteer, other_volunteer_case_contact)
      is_expected.not_to permit(volunteer, other_org_case_contact)
    end
  end

  permissions :restore? do
    it "allows same org casa_admins" do
      is_expected.to permit(casa_admin, case_contact)
      is_expected.to permit(casa_admin, draft_case_contact)
      is_expected.to permit(casa_admin, other_volunteer_case_contact)
      is_expected.not_to permit(casa_admin, other_org_case_contact)
    end

    it "does not allow supervisors" do
      is_expected.not_to permit(supervisor, case_contact)
      is_expected.not_to permit(supervisor, draft_case_contact)
      is_expected.not_to permit(supervisor, other_volunteer_case_contact)
      is_expected.not_to permit(supervisor, other_org_case_contact)
    end

    it "does not allow volunteers" do
      is_expected.not_to permit(volunteer, draft_case_contact)
      is_expected.not_to permit(volunteer, case_contact)
      is_expected.not_to permit(volunteer, other_volunteer_case_contact)
      is_expected.not_to permit(volunteer, other_org_case_contact)
    end
  end
end
