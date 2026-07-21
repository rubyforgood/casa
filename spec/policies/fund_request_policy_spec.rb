require "rails_helper"

RSpec.describe FundRequestPolicy, type: :policy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:supervisor) { build_stubbed(:supervisor) }
  let(:volunteer) { build_stubbed(:volunteer) }

  # NOTE: this policy is intentionally open - new?/create? are unconditionally
  # true, so there is no denied role. Access is constrained upstream by the
  # controller (FundRequestsController#verify_casa_case).
  permissions :new?, :create? do
    it "permits casa_admins" do
      expect(subject).to permit(casa_admin)
    end

    it "permits supervisors" do
      expect(subject).to permit(supervisor)
    end

    it "permits volunteers" do
      expect(subject).to permit(volunteer)
    end

    it "permits a nil user" do
      expect(subject).to permit(nil)
    end
  end
end
