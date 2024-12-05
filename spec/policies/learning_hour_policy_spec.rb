require "rails_helper"

RSpec.describe LearningHourPolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:supervisor) { build_stubbed(:supervisor) }
  let(:volunteer) { build_stubbed(:volunteer) }

  permissions :index? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)
    end

    it "allows supervisors" do
      expect(subject).to permit(supervisor)
    end

    it "allows volunteer" do
      expect(subject).to permit(volunteer)
    end
  end
end
