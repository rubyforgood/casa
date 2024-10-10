require "rails_helper"

RSpec.describe ContactTopicAnswerPolicy, type: :policy, aggregate_failures: true do
  let(:casa_org) { create :casa_org }
  let(:volunteer) { create :volunteer, :with_single_case, casa_org: }
  let(:supervisor) { create :supervisor, casa_org: }
  let(:casa_admin) { create :casa_admin, casa_org: }
  let(:all_casa_admin) { create :all_casa_admin }

  let(:contact_topic) { create :contact_topic, casa_org: }
  let(:casa_case) { volunteer.casa_cases.first }
  let(:case_contact) { create :case_contact, creator: volunteer }
  let(:contact_topic_answer) { create :contact_topic_answer, contact_topic:, case_contact: }

  let(:draft_case_contact) { create :case_contact, :started_status, casa_case: nil, creator: volunteer }
  let(:draft_contact_topic_answer) { create :contact_topic_answer, contact_topic:, case_contact: draft_case_contact }

  let(:same_case_volunteer) { create :volunteer, casa_org: }
  let(:same_case_volunteer_case_assignment) { create :case_assignment, volunteer: same_case_volunteer, casa_case: }
  let(:same_case_volunteer_case_contact) do
    same_case_volunteer_case_assignment
    create :case_contact, casa_case:, creator: same_case_volunteer
  end
  let(:same_case_volunteer_contact_topic_answer) do
    create :contact_topic_answer, contact_topic:, case_contact: same_case_volunteer_case_contact
  end

  let(:other_org) { create :casa_org }
  let(:other_org_volunteer) { create :volunteer, casa_org: other_org }
  let(:other_org_contact_topic) { create :contact_topic, casa_org: other_org }
  let(:other_org_casa_case) { create :casa_case, casa_org: other_org }
  let(:other_org_case_contact) { create :case_contact, casa_case: other_org_casa_case, creator: other_org_volunteer }
  let(:other_org_contact_topic_answer) do
    create :contact_topic_answer, case_contact: other_org_case_contact, contact_topic: other_org_contact_topic
  end

  subject { described_class }

  permissions :create?, :destroy? do
    it "does not permit a nil user" do
      is_expected.not_to permit(nil, contact_topic_answer)
    end

    it "permits a volunteer who created the case contact" do
      is_expected.to permit(volunteer, contact_topic_answer)
      is_expected.to permit(volunteer, draft_contact_topic_answer)
      is_expected.not_to permit(volunteer, same_case_volunteer_contact_topic_answer)
      is_expected.not_to permit(volunteer, other_org_contact_topic_answer)
    end

    it "permits same_org supervisors" do
      is_expected.to permit(supervisor, contact_topic_answer)
      is_expected.to permit(supervisor, draft_contact_topic_answer)
      is_expected.to permit(supervisor, same_case_volunteer_contact_topic_answer)

      is_expected.not_to permit(supervisor, other_org_contact_topic_answer)
    end

    it "permits same org casa admins" do
      is_expected.to permit(casa_admin, contact_topic_answer)
      is_expected.to permit(casa_admin, draft_contact_topic_answer)
      is_expected.to permit(casa_admin, same_case_volunteer_contact_topic_answer)

      is_expected.not_to permit(casa_admin, other_org_contact_topic_answer)
    end

    it "does not permit an all casa admin" do
      is_expected.not_to permit(all_casa_admin, contact_topic_answer)
    end
  end

  describe "Scope#resolve" do
    subject { described_class::Scope.new(user, ContactTopicAnswer.all).resolve }

    before do
      contact_topic_answer
      draft_contact_topic_answer
      same_case_volunteer_contact_topic_answer
      other_org_contact_topic_answer
    end

    context "when user is a visitor" do
      let(:user) { nil }

      it "returns no contact topic answers" do
        is_expected.not_to include(contact_topic_answer, other_org_contact_topic_answer)
      end
    end

    context "when user is a volunteer" do
      let(:user) { volunteer }

      it "returns contact topic answers of contacts created by the volunteer" do
        is_expected.to include(contact_topic_answer, draft_contact_topic_answer)
        is_expected.not_to include(same_case_volunteer_contact_topic_answer, other_org_contact_topic_answer)
      end
    end

    context "when user is a supervisor" do
      let(:user) { supervisor }

      it "returns same org contact topic answers" do
        is_expected
          .to include(contact_topic_answer, draft_contact_topic_answer, same_case_volunteer_contact_topic_answer)
        is_expected.not_to include(other_org_contact_topic_answer)
      end
    end

    context "when user is a casa_admin" do
      let(:user) { casa_admin }

      it "includes same org contact topic answers" do
        is_expected
          .to include(contact_topic_answer, draft_contact_topic_answer, same_case_volunteer_contact_topic_answer)
        is_expected.not_to include(other_org_contact_topic_answer)
      end
    end

    context "when user is an all_casa_admin" do
      let(:user) { all_casa_admin }

      it "returns no contact topic answers" do
        is_expected.not_to include(contact_topic_answer, other_org_contact_topic_answer)
      end
    end
  end
end
