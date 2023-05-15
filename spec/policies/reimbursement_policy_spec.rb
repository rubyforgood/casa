require "rails_helper"

RSpec.describe ReimbursementPolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:volunteer) { build_stubbed(:volunteer) }
  let(:supervisor) { build_stubbed(:supervisor) }
  let(:organization) { build(:casa_org, users: [volunteer, supervisor, casa_admin]) }

  context "when org reimbursement is enabled" do
    permissions :index?, :change_complete_status? do
      it { is_expected.to permit(casa_admin) }
      it { is_expected.to_not permit(supervisor) }
      it { is_expected.to_not permit(volunteer) }
    end

    permissions :datatable? do
      it { is_expected.to permit(casa_admin) }
      it { is_expected.to_not permit(supervisor) }
      it { is_expected.to_not permit(volunteer) }
    end
  end

  context "when org reimbursement is disabled" do
    before do
      organization.show_driving_reimbursement = false
    end

    permissions :index?, :change_complete_status? do
      it { is_expected.to_not permit(casa_admin) }
    end

    permissions :datatable? do
      it { is_expected.to_not permit(casa_admin) }
    end
  end

  describe "ReimbursementPolicy::Scope #resolve" do
    subject { described_class::Scope.new(user, scope).resolve }

    let(:user) { build_stubbed(:casa_admin, casa_org: casa_org1) }
    let(:scope) { CaseContact.joins(:casa_case) }
    let(:casa_org1) { create(:casa_org) }
    let(:casa_case1) { create(:casa_case, casa_org: casa_org1) }
    let(:casa_case2) { create(:casa_case, casa_org: create(:casa_org)) }

    let!(:contact1) { create(:case_contact, casa_case: casa_case1) }
    let!(:contact2) { create(:case_contact, casa_case: casa_case2) }

    it { is_expected.to include(contact1) }
    it { is_expected.not_to include(contact2) }
  end
end
