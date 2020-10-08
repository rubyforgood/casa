require "rails_helper"

RSpec.describe CasaAdminPolicy do
  subject { described_class }

  let(:organization) { create(:casa_org) }
  let(:casa_admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }

  permissions :index? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)
    end

    it "allows supervisor" do
      expect(subject).to_not permit(supervisor)
    end

    it "allows supervisor" do
      expect(subject).to_not permit(volunteer)
    end
  end
end
