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
      is_expected.to permit(casa_admin, contact_topic)
    end

    it "allows does not allow different org casa_admins" do
      is_expected.to_not permit(other_org_admin, contact_topic)
    end
    it "does not permit supervisor" do
      is_expected.to_not permit(supervisor, contact_topic)
    end

    it "does not permit volunteer" do
      is_expected.to_not permit(volunteer, contact_topic)
    end
  end
end
