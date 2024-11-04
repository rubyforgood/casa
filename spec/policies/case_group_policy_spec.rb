require "rails_helper"

RSpec.describe CaseGroupPolicy, type: :policy do
  subject { described_class }

  let(:casa_org) { create :casa_org }
  let(:volunteer) { create :volunteer, :with_casa_cases, casa_org: }
  let(:supervisor) { create :supervisor, casa_org: }
  let(:casa_admin) { create :casa_admin, casa_org: }
  let(:all_casa_admin) { create :all_casa_admin }

  let(:case_group) { create :case_group, casa_org: }
  let(:volunteer_case_group) { create :case_group, casa_org:, casa_cases: volunteer.casa_cases }

  permissions :new?, :create?, :destroy?, :edit?, :show?, :update? do
    it "does not permit a nil user" do
      expect(described_class).not_to permit(nil, case_group)
    end

    it "does not permit a volunteer" do
      expect(described_class).not_to permit(volunteer, case_group)
    end

    it "does not permit a volunteer assigned to the case group" do
      expect(described_class).not_to permit(volunteer, volunteer_case_group)
    end

    it "permits a supervisor" do
      expect(described_class).to permit(supervisor, case_group)
    end

    it "does not permit a supervisor for a different casa org" do
      other_org_supervisor = create :supervisor, casa_org: create(:casa_org)
      expect(described_class).not_to permit(other_org_supervisor, case_group)
    end

    it "permits a casa admin" do
      expect(described_class).to permit(casa_admin, case_group)
    end

    it "does not permit a casa admin for a different casa org" do
      other_org_casa_admin = create :casa_admin, casa_org: create(:casa_org)
      expect(described_class).not_to permit(other_org_casa_admin, case_group)
    end

    it "does not permit an all casa admin" do
      expect(described_class).not_to permit(all_casa_admin, case_group)
    end
  end

  permissions :index? do
    it "does not permit a nil user" do
      expect(described_class).not_to permit(nil, :case_group)
    end

    it "does not permit a volunteer" do
      expect(described_class).not_to permit(volunteer, :case_group)
    end

    it "permits a supervisor" do
      expect(described_class).to permit(supervisor, :case_group)
    end

    it "permits a casa admin" do
      expect(described_class).to permit(casa_admin, :case_group)
    end

    it "does not permit an all casa admin" do
      expect(described_class).not_to permit(all_casa_admin, :case_group)
    end
  end

  describe "Scope#resolve" do
    subject { described_class::Scope.new(user, CaseGroup.all).resolve }

    let!(:casa_org_case_group) { create :case_group, casa_org: }
    let!(:other_casa_org_case_group) { create :case_group, casa_org: create(:casa_org) }

    context "when user is a visitor" do
      let(:user) { nil }

      specify do
        expect(subject).not_to include(casa_org_case_group)
        expect(subject).not_to include(other_casa_org_case_group)
      end
    end

    context "when user is a volunteer" do
      let(:user) { volunteer }
      let!(:user_case_group) { volunteer_case_group }

      specify do
        expect(subject).not_to include(user_case_group)
        expect(subject).not_to include(casa_org_case_group)
        expect(subject).not_to include(other_casa_org_case_group)
      end
    end

    context "when user is a supervisor" do
      let(:user) { supervisor }

      specify do
        expect(subject).to include(casa_org_case_group)
        expect(subject).not_to include(other_casa_org_case_group)
      end
    end

    context "when user is a casa_admin" do
      let(:user) { casa_admin }

      specify do
        expect(subject).to include(casa_org_case_group)
        expect(subject).not_to include(other_casa_org_case_group)
      end
    end

    context "when user is an all_casa_admin" do
      let(:user) { all_casa_admin }

      specify do
        expect(subject).not_to include(casa_org_case_group)
        expect(subject).not_to include(other_casa_org_case_group)
      end
    end
  end
end
