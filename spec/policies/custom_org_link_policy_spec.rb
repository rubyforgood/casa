require "rails_helper"

RSpec.describe CustomOrgLinkPolicy, type: :policy do
  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:supervisor) { build_stubbed(:supervisor) }
  let(:volunteer) { build_stubbed(:volunteer) }

  permissions :new?, :create? do
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
    subject(:resolved_scope) { described_class::Scope.new(user, CustomOrgLink.all).resolve }

    let(:casa_org) { create(:casa_org) }
    let!(:custom_org_link) { create(:custom_org_link, casa_org: casa_org) }
    let!(:other_org_custom_org_link) { create(:custom_org_link) }

    context "when user is a casa admin" do
      let(:user) { create(:casa_admin, casa_org: casa_org) }

      it "resolves only links from the admin's organization" do
        expect(resolved_scope).to contain_exactly(custom_org_link)
      end
    end

    context "when user is a supervisor" do
      let(:user) { create(:supervisor, casa_org: casa_org) }

      it "resolves no links" do
        expect(resolved_scope).to be_empty
      end
    end

    context "when user is a volunteer" do
      let(:user) { create(:volunteer, casa_org: casa_org) }

      it "resolves no links" do
        expect(resolved_scope).to be_empty
      end
    end
  end

  permissions :edit?, :update? do
    let(:casa_org) { create(:casa_org) }
    let(:admin) { create(:casa_admin, casa_org: casa_org) }

    it "allows casa_admins in the record's org" do
      expect(described_class).to permit(admin, create(:custom_org_link, casa_org: casa_org))
    end

    it "does not permit casa_admins from another org" do
      expect(described_class).not_to permit(admin, create(:custom_org_link, casa_org: create(:casa_org)))
    end

    it "does not permit supervisors or volunteers" do
      record = create(:custom_org_link, casa_org: casa_org)
      expect(described_class).not_to permit(create(:supervisor, casa_org: casa_org), record)
      expect(described_class).not_to permit(create(:volunteer, casa_org: casa_org), record)
    end
  end
end
