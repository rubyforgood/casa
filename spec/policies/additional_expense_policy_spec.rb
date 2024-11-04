require "rails_helper"

RSpec.describe AdditionalExpensePolicy, :aggregate_failures, type: :policy do
  subject { described_class }

  let(:casa_org) { create :casa_org }
  let(:volunteer) { create :volunteer, :with_single_case, casa_org: }
  let(:supervisor) { create :supervisor, casa_org: }
  let(:casa_admin) { create :casa_admin, casa_org: }
  let(:all_casa_admin) { create :all_casa_admin }

  let(:casa_case) { volunteer.casa_cases.first }
  let(:case_contact) { create :case_contact, casa_case:, creator: volunteer }
  let(:additional_expense) { create :additional_expense, case_contact: }

  let(:draft_case_contact) { create :case_contact, :started_status, casa_case: nil, creator: volunteer }
  let(:draft_additional_expense) { create :additional_expense, case_contact: draft_case_contact }
  let(:new_additional_expense) do
    build :additional_expense, case_contact: draft_case_contact, other_expense_amount: 0, other_expenses_describe: ""
  end

  let(:same_case_volunteer) { create :volunteer, casa_org: }
  let(:same_case_volunteer_case_assignment) { create :case_assignment, volunteer: same_case_volunteer, casa_case: }
  let(:same_case_volunteer_case_contact) do
    same_case_volunteer_case_assignment
    create :case_contact, casa_case:, creator: same_case_volunteer
  end
  let(:same_case_volunteer_additional_expense) do
    create :additional_expense, case_contact: same_case_volunteer_case_contact
  end

  let(:other_org) { create :casa_org }
  let(:other_org_volunteer) { create :volunteer, casa_org: other_org }
  let(:other_org_casa_case) { create :casa_case, casa_org: other_org }
  let(:other_org_case_contact) { create :case_contact, casa_case: other_org_casa_case, creator: other_org_volunteer }
  let(:other_org_additional_expense) { create :additional_expense, case_contact: other_org_case_contact }

  permissions :create?, :destroy? do
    it "does not permit a nil user" do
      expect(subject).not_to permit(nil, additional_expense)
    end

    it "permits volunteers assigned to the expense's case contact" do
      expect(subject).to permit(volunteer, additional_expense)
      expect(subject).to permit(volunteer, draft_additional_expense)
      expect(subject).to permit(volunteer, new_additional_expense)

      expect(subject).not_to permit(volunteer, same_case_volunteer_additional_expense)
      expect(subject).not_to permit(volunteer, other_org_additional_expense)
    end

    it "permits same org supervisors" do
      expect(subject).to permit(supervisor, additional_expense)
      expect(subject).to permit(supervisor, draft_additional_expense)
      expect(subject).to permit(supervisor, draft_additional_expense)
      expect(subject).to permit(supervisor, same_case_volunteer_additional_expense)

      expect(subject).not_to permit(supervisor, other_org_additional_expense)
    end

    it "permits same org casa admins" do
      expect(subject).to permit(casa_admin, additional_expense)
      expect(subject).to permit(casa_admin, draft_additional_expense)
      expect(subject).to permit(casa_admin, new_additional_expense)
      expect(subject).to permit(casa_admin, same_case_volunteer_additional_expense)

      expect(subject).not_to permit(casa_admin, other_org_additional_expense)
    end

    it "does not permit an all casa admin" do
      expect(subject).not_to permit(all_casa_admin, additional_expense)
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

      it "returns no expenses" do
        expect(subject).not_to include(additional_expense, other_org_additional_expense)
      end
    end

    context "when user is a volunteer" do
      let(:user) { volunteer }

      it "includes expenses for contacts created by volunteer only" do
        expect(subject).to include(additional_expense, draft_additional_expense)
        expect(subject).not_to include(same_case_volunteer_additional_expense, other_org_additional_expense)
      end
    end

    context "when user is a supervisor" do
      let(:user) { supervisor }

      it "includes same org expenses only" do
        expect(subject).to include(additional_expense, draft_additional_expense, same_case_volunteer_additional_expense)
        expect(subject).not_to include(other_org_additional_expense)
      end
    end

    context "when user is a casa_admin" do
      let(:user) { casa_admin }

      it "includes same org expenses only" do
        expect(subject).to include(additional_expense, draft_additional_expense, draft_additional_expense)
        expect(subject).not_to include(other_org_additional_expense)
      end
    end

    context "when user is an all_casa_admin" do
      let(:user) { all_casa_admin }

      it "returns no expenses" do
        expect(subject).not_to include(additional_expense, other_org_additional_expense)
      end
    end
  end
end
