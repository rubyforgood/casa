require "rails_helper"

RSpec.describe LearningHourTopicPolicy, type: :policy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:supervisor) { build_stubbed(:supervisor) }
  let(:volunteer) { build_stubbed(:volunteer) }

  permissions :new?, :create?, :edit?, :update? do
    it "permits casa_admins" do
      expect(subject).to permit(casa_admin)
    end

    it "does not permit supervisors" do
      expect(subject).not_to permit(supervisor)
    end

    it "does not permit volunteers" do
      expect(subject).not_to permit(volunteer)
    end
  end
end
