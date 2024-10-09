require "rails_helper"

RSpec.describe AdditionalExpensePolicy, type: :policy, aggregate_failures: true do
  let(:casa_org) { create :casa_org }
  let(:volunteer) { create :volunteer, :with_single_case, casa_org: }
  let(:supervisor) { create :supervisor, casa_org: }
  let(:casa_admin) { create :casa_admin, casa_org: }
  let(:all_casa_admin) { create :all_casa_admin }

  let(:casa_case) { volunteer.casa_cases.first }
  let(:case_contact) { create :case_contact, casa_case:, creator: volunteer }
  let(:additional_expense) { create :additional_expense, case_contact: }

  let(:draft_case_contact) { create :case_contact, :started_status, casa_case: nil, creator: volunteer }
  let(:draft_additional_expense) { create :additional_expense, case_contact: draft_case_contact}
  let(:new_additional_expense) do
    build :additional_expense, case_contact: draft_case_contact, other_expense_amount: 0, other_expenses_describe: ""
  end

  let(:same_case_volunteer) { create :volunteer, casa_org: }
  let(:same_case_volunteer_case_assignment) { create :case_assignment, volunteer: same_case_volunteer, casa_case: }
  let(:same_case_volunteer_case_contact) { create :case_contact, casa_case:, creator: same_case_volunteer }
  let(:same_case_volunteer_additional_expense) do
    create :additional_expense, case_contact: same_case_volunteer_case_contact
  end

  let(:other_org) { create :casa_org }
  let(:other_org_volunteer) { create :volunteer, casa_org: other_org }
  let(:other_org_casa_case) { create :casa_case, casa_org: other_org }
  let(:other_org_case_contact) { create :case_contact, casa_case: other_org_casa_case, creator: other_org_volunteer }
  let(:other_org_additional_expense) { create :additional_expense, case_contact: other_org_case_contact }

  subject { described_class }

  permissions :create?, :destroy? do
    it "does not permit a nil user" do
      expect(described_class).not_to permit(nil, additional_expense)
    end

    it "permits volunteers assigned to the expense's case contact" do
      same_case_volunteer_case_assignment
      expect(described_class).to permit(volunteer, additional_expense)
      expect(described_class).to permit(volunteer, draft_additional_expense)
      expect(described_class).to permit(volunteer, new_additional_expense)

      expect(same_case_volunteer.casa_cases).to include(casa_case)
      expect(described_class).not_to permit(same_case_volunteer, additional_expense)
      expect(described_class).not_to permit(same_case_volunteer, draft_additional_expense)
    end

    it "permits same org supervisors" do
      expect(described_class).to permit(supervisor, additional_expense)
      expect(described_class).to permit(supervisor, draft_additional_expense)
      expect(described_class).to permit(supervisor, new_additional_expense)

      other_org_supervisor = create :supervisor, casa_org: create(:casa_org)
      expect(described_class).not_to permit(other_org_supervisor, additional_expense)
    end

    it "permits same org casa admins" do
      expect(described_class).to permit(casa_admin, additional_expense)
      expect(described_class).to permit(casa_admin, draft_additional_expense)
      expect(described_class).to permit(casa_admin, new_additional_expense)

      other_org_casa_admin = create :casa_admin, casa_org: create(:casa_org)
      expect(described_class).not_to permit(other_org_casa_admin, additional_expense)
    end

    it "does not permit an all casa admin" do
      expect(described_class).not_to permit(all_casa_admin, additional_expense)
    end
  end

  describe "Scope#resolve" do
    subject { described_class::Scope.new(user, AdditionalExpense.all).resolve }

    before do
      additional_expense
      draft_additional_expense
      same_case_volunteer_additional_expense
      other_org_additional_expense
    end

    context "when user is a visitor" do
      let(:user) { nil }

      it { is_expected.not_to include(additional_expense) }
      it { is_expected.not_to include(other_org_additional_expense) }
    end

    context "when user is a volunteer" do
      let(:user) { volunteer }

      it { is_expected.to include(additional_expense) }
      it { is_expected.to include(draft_additional_expense) }
      it { is_expected.not_to include(same_case_volunteer_additional_expense) }
      it { is_expected.not_to include(other_org_additional_expense) }
    end

    context "when user is a supervisor" do
      let(:user) { supervisor }

      it { is_expected.to include(additional_expense) }
      it { is_expected.to include(draft_additional_expense) }
      it { is_expected.to include(same_case_volunteer_additional_expense) }
      it { is_expected.not_to include(other_org_additional_expense) }
    end

    context "when user is a casa_admin" do
      let(:user) { casa_admin }

      it { is_expected.to include(additional_expense) }
      it { is_expected.to include(draft_additional_expense) }
      it { is_expected.to include(same_case_volunteer_additional_expense) }
      it { is_expected.not_to include(other_org_additional_expense) }
    end

    context "when user is an all_casa_admin" do
      let(:user) { all_casa_admin }

      it { is_expected.not_to include(additional_expense) }
      it { is_expected.not_to include(other_org_additional_expense) }
    end
  end
end
