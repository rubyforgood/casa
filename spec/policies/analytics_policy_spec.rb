require "rails_helper"

RSpec.describe AnalyticsPolicy do
  subject { described_class }

  let(:casa_org) { build_stubbed(:casa_org) }
  let(:casa_admin) { build_stubbed(:casa_admin, casa_org: casa_org) }
  let(:supervisor) { build_stubbed(:supervisor, casa_org: casa_org) }
  let(:volunteer) { build_stubbed(:volunteer, casa_org: casa_org) }

  permissions :index? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)
    end

    it "allows supervisors" do
      expect(subject).to permit(supervisor)
    end

    it "does not allow volunteers" do
      expect(subject).not_to permit(volunteer)
    end
  end
end
