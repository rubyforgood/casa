require "rails_helper"

RSpec.describe ContactTypePolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:volunteer) { build_stubbed(:volunteer) }
  let(:supervisor) { build_stubbed(:supervisor) }

  permissions :new?, :create? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)
    end

    it "does not permit supervisor" do
      expect(subject).not_to permit(supervisor)
    end

    it "does not permit volunteer" do
      expect(subject).not_to permit(volunteer)
    end
  end

  permissions :edit?, :update? do
    let(:casa_org) { create(:casa_org) }
    let(:admin) { create(:casa_admin, casa_org: casa_org) }

    it "allows casa_admins in the record's org" do
      expect(subject).to permit(admin, create(:contact_type, contact_type_group: create(:contact_type_group, casa_org: casa_org)))
    end

    it "does not permit casa_admins from another org" do
      expect(subject).not_to permit(admin, create(:contact_type, contact_type_group: create(:contact_type_group, casa_org: create(:casa_org))))
    end

    it "does not permit supervisors or volunteers" do
      record = create(:contact_type, contact_type_group: create(:contact_type_group, casa_org: casa_org))
      expect(subject).not_to permit(create(:supervisor, casa_org: casa_org), record)
      expect(subject).not_to permit(create(:volunteer, casa_org: casa_org), record)
    end
  end
end
