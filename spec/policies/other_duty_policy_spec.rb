require "rails_helper"

RSpec.describe OtherDutyPolicy do
  subject { described_class }

  let(:casa_org) { build(:casa_org, other_duties_enabled: true) }
  let(:casa_admin) { build(:casa_admin, casa_org:) }
  let(:supervisor) { build(:supervisor, casa_org:) }
  let(:volunteer) { build(:volunteer, casa_org:) }

  permissions :index? do
    it "allows all roles when org has other duties enabled" do
      expect(subject).to permit(casa_admin)
      expect(subject).to permit(supervisor)
      expect(subject).to permit(volunteer)

      casa_org.other_duties_enabled = false

      expect(subject).not_to permit(casa_admin)
      expect(subject).not_to permit(supervisor)
      expect(subject).not_to permit(volunteer)
    end
  end
end
