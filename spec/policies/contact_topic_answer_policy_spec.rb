require "rails_helper"

RSpec.describe ContactTopicAnswerPolicy, type: :policy do
  let(:casa_org) { create :casa_org }
  let(:volunteer) { create :volunteer, :with_single_case, casa_org: }
  let(:supervisor) { create :supervisor, casa_org: }
  let(:casa_admin) { create :casa_admin, casa_org: }
  let(:all_casa_admin) { create :all_casa_admin }

  let(:contact_topic) { create :contact_topic, casa_org: }
  let(:casa_case) { volunteer.casa_cases.first }
  let(:case_contact) { create :case_contact, casa_case:, creator: volunteer }
  let!(:contact_topic_answer) { create :contact_topic_answer, contact_topic:, case_contact: }

  let(:same_org_volunteer) { create :volunteer, casa_org: }
  let!(:same_org_volunteer_case_assignment) { create :case_assignment, volunteer: same_org_volunteer, casa_case: }

  subject { described_class }

  permissions :create?, :destroy? do
    it "does not permit a nil user" do
      expect(described_class).not_to permit(nil, contact_topic_answer)
    end

    it "permits a volunteer assigned to the contact topic answer case" do
      expect(described_class).to permit(volunteer, contact_topic_answer)
    end

    it "does not permit a volunteer who did not create the case contact" do
      expect(same_org_volunteer.casa_cases).to include(casa_case)
      expect(described_class).not_to permit(same_org_volunteer, contact_topic_answer)
    end

    it "permits a supervisor" do
      expect(described_class).to permit(supervisor, contact_topic_answer)
    end

    it "does not permit a supervisor for a different casa org" do
      other_org_supervisor = create :supervisor, casa_org: create(:casa_org)
      expect(described_class).not_to permit(other_org_supervisor, contact_topic_answer)
    end

    it "permits a casa admin" do
      expect(described_class).to permit(casa_admin, contact_topic_answer)
    end

    it "does not permit a casa admin for a different casa org" do
      other_org_casa_admin = create :casa_admin, casa_org: create(:casa_org)
      expect(described_class).not_to permit(other_org_casa_admin, contact_topic_answer)
    end

    it "does not permit an all casa admin" do
      expect(described_class).not_to permit(all_casa_admin, contact_topic_answer)
    end
  end

  describe "Scope#resolve" do
    let(:same_org_volunteer_case_contact) { create :case_contact, casa_case:, creator: same_org_volunteer }
    let!(:same_org_other_volunteer_contact_topic_answer) do
      create :contact_topic_answer, contact_topic:, case_contact: same_org_volunteer_case_contact
    end

    let(:other_volunteer_case_contact) { create :case_contact, casa_case:, creator: other_volunteer }
    let!(:other_volunteer_contact_topic_answer) { create :contact_topic_answer, contact_topic:, case_contact: other_org_case_contact }

    let(:other_org) { create :casa_org }
    let(:other_org_volunteer) { create :volunteer, casa_org: other_org }
    let(:other_org_contact_topic) { create :contact_topic, casa_org: other_org }
    let(:other_org_casa_case) { create :casa_case, casa_org: other_org }
    let(:other_org_case_contact) { create :case_contact, casa_case: other_org_casa_case, creator: other_org_volunteer }
    let!(:other_org_contact_topic_answer) { create :contact_topic_answer, case_contact: other_org_case_contact, contact_topic: other_org_contact_topic }

    subject { described_class::Scope.new(user, ContactTopicAnswer.all).resolve }

    context "when user is a visitor" do
      let(:user) { nil }

      it { is_expected.not_to include(contact_topic_answer) }
      it { is_expected.not_to include(other_org_contact_topic_answer) }
    end

    context "when user is a volunteer" do
      let(:user) { volunteer }

      it { is_expected.to include(contact_topic_answer) }
      it { is_expected.not_to include(other_volunteer_contact_topic_answer) }
      it { is_expected.not_to include(other_org_contact_topic_answer) }
    end

    context "when user is a supervisor" do
      let(:user) { supervisor }

      it { is_expected.to include(contact_topic_answer) }
      it { is_expected.not_to include(other_org_contact_topic_answer) }
    end

    context "when user is a casa_admin" do
      let(:user) { casa_admin }

      it { is_expected.to include(contact_topic_answer) }
      it { is_expected.not_to include(other_org_contact_topic_answer) }
    end

    context "when user is an all_casa_admin" do
      let(:user) { all_casa_admin }

      it { is_expected.not_to include(contact_topic_answer) }
      it { is_expected.not_to include(other_org_contact_topic_answer) }
    end
  end
end
