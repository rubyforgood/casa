require "rails_helper"

RSpec.describe ContactTypePolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:volunteer) { build_stubbed(:volunteer) }
  let(:supervisor) { build_stubbed(:supervisor) }

  permissions :new?, :create?, :edit?, :update? do
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
end
