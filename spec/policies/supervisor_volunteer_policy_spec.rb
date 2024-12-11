require "rails_helper"

RSpec.describe SupervisorVolunteerPolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:volunteer) { build_stubbed(:volunteer) }
  let(:supervisor) { build_stubbed(:supervisor) }

  permissions :create? do
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

  permissions :unassign? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)
    end

    it "allows supervisor" do
      expect(subject).to permit(supervisor)
    end

    it "does not permit volunteer" do
      expect(subject).not_to permit(volunteer)
    end
  end
end
