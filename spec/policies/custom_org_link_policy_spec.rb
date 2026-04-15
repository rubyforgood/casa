require "rails_helper"

RSpec.describe CustomOrgLinkPolicy, type: :policy do
  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:supervisor) { build_stubbed(:supervisor) }
  let(:volunteer) { build_stubbed(:volunteer) }

  permissions :new?, :create?, :edit?, :update? do
    it "permits casa_admins" do
      expect(described_class).to permit(casa_admin)
    end

    it "does not permit supervisor" do
      expect(described_class).not_to permit(supervisor)
    end

    it "does not permit volunteer" do
      expect(described_class).not_to permit(volunteer)
    end
  end

  describe "Scope#resolve" do
    subject { described_class::Scope.new(user, CustomOrgLink.all).resolve }

    let(:casa_org) { create(:casa_org) }
    let(:other_org) { create(:casa_org) }
    let!(:org_link) { create(:custom_org_link, casa_org: casa_org) }
    let!(:other_org_link) { create(:custom_org_link, casa_org: other_org) }

    context "when user is a casa admin" do
      let(:user) { create(:casa_admin, casa_org: casa_org) }

      it "returns links from the admin's organization only" do
        expect(subject).to include(org_link)
        expect(subject).not_to include(other_org_link)
      end
    end

    context "when user is a supervisor" do
      let(:user) { create(:supervisor, casa_org: casa_org) }

      it "returns no links" do
        expect(subject).to be_empty
      end
    end

    context "when user is a volunteer" do
      let(:user) { create(:volunteer, casa_org: casa_org) }

      it "returns no links" do
        expect(subject).to be_empty
      end
    end
  end
end
