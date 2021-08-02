require "rails_helper"

RSpec.describe Supervisor, type: :model do
  subject(:supervisor) { create :supervisor }

  describe "#role" do
    it { expect(supervisor.role).to eq "Supervisor" }

    it { is_expected.to have_many(:supervisor_volunteers) }
    it { is_expected.to have_many(:active_supervisor_volunteers) }
    it { is_expected.to have_many(:unassigned_supervisor_volunteers) }
    it { is_expected.to have_many(:volunteers).through(:active_supervisor_volunteers) }
    it { is_expected.to have_many(:volunteers_ever_assigned).through(:supervisor_volunteers) }
  end

  describe "invitation expiration" do
    let!(:mail) { supervisor.invite! }
    let(:expiration_date) { I18n.l(supervisor.invitation_due_at, format: :full, default: nil) }
    let(:two_weeks) { I18n.l(2.weeks.from_now, format: :full, default: nil) }

    it { expect(expiration_date).to eq two_weeks }
    it "expires invitation token after two weeks" do
      travel_to 2.weeks.from_now

      user = User.accept_invitation!(invitation_token: supervisor.invitation_token)
      expect(user.errors.full_messages).to include("Invitation token is invalid")
    end
  end

  describe "pending volunteers" do
    let(:volunteer) { create(:volunteer) }
    let(:assign_volunteer) { create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer) }

    it "returns volunteers invited by the supervisor" do
      volunteer.invite!(supervisor)
      expect(supervisor.pending_volunteers).to eq([volunteer])
    end

    it "returns volunteers invited by others but assigned to supervisor" do
      volunteer.invite!
      assign_volunteer
      expect(supervisor.pending_volunteers).to eq([volunteer])
    end
  end
end
