require "rails_helper"

RSpec.describe ContactTopicPolicy, type: :policy do
  subject { described_class }

  let(:contact_topic) { build(:contact_topic, casa_org: organization) }

  let(:organization) { build(:casa_org) }
  let(:casa_admin) { create(:casa_admin, casa_org: organization) }
  let(:other_org_admin) { create(:casa_admin) }
  let(:volunteer) { build(:volunteer, casa_org: organization) }
  let(:supervisor) { build(:supervisor, casa_org: organization) }

  permissions :create?, :edit?, :new?, :show?, :soft_delete?, :update? do
    it "allows same org casa_admins" do
      expect(subject).to permit(casa_admin, contact_topic)
    end

    it "allows does not allow different org casa_admins" do
      expect(subject).not_to permit(other_org_admin, contact_topic)
    end

    it "does not permit supervisor" do
      expect(subject).not_to permit(supervisor, contact_topic)
    end

    it "does not permit volunteer" do
      expect(subject).not_to permit(volunteer, contact_topic)
    end
  end
end
