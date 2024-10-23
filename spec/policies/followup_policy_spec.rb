require "rails_helper"

RSpec.describe FollowupPolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:volunteer) { build_stubbed(:volunteer) }
  let(:supervisor) { build_stubbed(:supervisor) }

  permissions :create?, :resolve? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)
    end

    it "allows supervisor" do
      expect(subject).to permit(supervisor)
    end

    it "allows volunteer" do
      expect(subject).to permit(volunteer)
    end
  end
end
