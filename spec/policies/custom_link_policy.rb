require "rails_helper"

RSpec.describe CustomLinkPolicy do
  subject { described_class }

  let(:user) { create(:user, casa_org: organization) }
  let(:casa_org) { create :casa_org }
  let(:organization) { build(:casa_org) }
  let(:volunteer) { create :volunteer, :with_single_case, casa_org: organization }
  let(:supervisor) { create :supervisor, casa_org: organization }
  let(:casa_admin) { create :casa_admin, casa_org: organization }
  let(:all_casa_admin) { create :all_casa_admin }
  let(:custom_link) { create(:custom_link, casa_org: organization) }
  let(:valid_attributes) { {text: "Link Text", url: "http://example.com", active: true, casa_org: organization} }
  let(:invalid_attributes) { {text: "", url: "invalid", active: nil} }
  let(:other_org_admin) { create(:casa_admin) }

  permissions :create?, :edit?, :new?, :show?, :update? do
    it "allows same org casa_admins" do
      expect(subject).to permit(casa_admin, custom_link)
    end

    it "does not allow different org casa_admins" do
      expect(subject).not_to permit(other_org_admin, custom_link)
    end

    it "does not permit supervisor" do
      expect(subject).not_to permit(supervisor, custom_link)
    end

    it "does not permit volunteer" do
      expect(subject).not_to permit(volunteer, custom_link)
    end
  end
end
