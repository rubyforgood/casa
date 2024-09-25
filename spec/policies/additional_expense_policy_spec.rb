require "rails_helper"

RSpec.describe AdditionalExpensePolicy, type: :policy do
  let(:casa_org) { create :casa_org }
  let(:volunteer) { create :volunteer, :with_single_case, casa_org: }
  let(:supervisor) { create :supervisor, casa_org: }
  let(:casa_admin) { create :casa_admin, casa_org: }
  let(:all_casa_admin) { create :all_casa_admin }

  let(:casa_case) { volunteer.casa_cases.first }
  let(:case_contact) { create :case_contact, casa_case:, creator: volunteer }
  let!(:additional_expense) { create :additional_expense, case_contact: }

  let(:same_org_volunteer) { create :volunteer, casa_org: }
  let!(:same_org_volunteer_case_assignment) { create :case_assignment, volunteer: same_org_volunteer, casa_case: }

  subject { described_class }

  permissions :create?, :destroy? do
    it "does not permit a nil user" do
      expect(described_class).not_to permit(nil, additional_expense)
    end

    it "permits a volunteer assigned to the expense's case contact" do
      expect(described_class).to permit(volunteer, additional_expense)
    end

    it "does not permit a volunteer who did not create the case contact" do
      expect(same_org_volunteer.casa_cases).to include(casa_case)
      expect(described_class).not_to permit(same_org_volunteer, additional_expense)
    end

    it "permits a supervisor" do
      expect(described_class).to permit(supervisor, additional_expense)
    end

    it "does not permit a supervisor for a different casa org" do
      other_org_supervisor = create :supervisor, casa_org: create(:casa_org)
      expect(described_class).not_to permit(other_org_supervisor, additional_expense)
    end

    it "permits a casa admin" do
      expect(described_class).to permit(casa_admin, additional_expense)
    end

    it "does not permit a casa admin for a different casa org" do
      other_org_casa_admin = create :casa_admin, casa_org: create(:casa_org)
      expect(described_class).not_to permit(other_org_casa_admin, additional_expense)
    end

    it "does not permit an all casa admin" do
      expect(described_class).not_to permit(all_casa_admin, additional_expense)
    end
  end

  describe "Scope#resolve" do
    let(:same_org_volunteer_case_contact) { create :case_contact, casa_case:, creator: same_org_volunteer }
    let!(:same_org_other_volunteer_additional_expense) do
      create :additional_expense, case_contact: same_org_volunteer_case_contact
    end

    let(:other_volunteer_case_contact) { create :case_contact, casa_case:, creator: other_volunteer }
    let!(:other_volunteer_additional_expense) { create :additional_expense, case_contact: other_org_case_contact }

    let(:other_org) { create :casa_org }
    let(:other_org_volunteer) { create :volunteer, casa_org: other_org }
    let(:other_org_casa_case) { create :casa_case, casa_org: other_org }
    let(:other_org_case_contact) { create :case_contact, casa_case: other_org_casa_case, creator: other_org_volunteer }
    let!(:other_org_additional_expense) { create :additional_expense, case_contact: other_org_case_contact }

    subject { described_class::Scope.new(user, AdditionalExpense.all).resolve }

    context "when user is a visitor" do
      let(:user) { nil }

      it { is_expected.not_to include(additional_expense) }
      it { is_expected.not_to include(other_org_additional_expense) }
    end

    context "when user is a volunteer" do
      let(:user) { volunteer }

      it { is_expected.to include(additional_expense) }
      it { is_expected.not_to include(other_volunteer_additional_expense) }
      it { is_expected.not_to include(other_org_additional_expense) }
    end

    context "when user is a supervisor" do
      let(:user) { supervisor }

      it { is_expected.to include(additional_expense) }
      it { is_expected.not_to include(other_org_additional_expense) }
    end

    context "when user is a casa_admin" do
      let(:user) { casa_admin }

      it { is_expected.to include(additional_expense) }
      it { is_expected.not_to include(other_org_additional_expense) }
    end

    context "when user is an all_casa_admin" do
      let(:user) { all_casa_admin }

      it { is_expected.not_to include(additional_expense) }
      it { is_expected.not_to include(other_org_additional_expense) }
    end
  end
end
