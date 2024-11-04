require "rails_helper"

RSpec.describe Supervisor, type: :model do
  include Devise::Test::IntegrationHelpers

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
      travel_back
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

  describe "not_signed_in_nor_have_case_contacts_volunteers" do
    subject { supervisor.inactive_volunteers }

    let(:supervisor) { create(:supervisor) }
    let(:volunteer) { create(:volunteer, last_sign_in_at: 31.days.ago) }
    let(:other_volunteer) { create(:volunteer, last_sign_in_at: 29.days.ago) }

    before do
      create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer)
      create(:supervisor_volunteer, supervisor: supervisor, volunteer: other_volunteer)
    end

    context "when volunteer has logged in in the last 30 days" do
      let(:volunteer) { create(:volunteer, last_sign_in_at: 29.days.ago) }

      it { is_expected.to be_empty }

      context "when volunteer then logged out" do
        it "is empty" do
          sign_out volunteer

          expect(subject).to be_empty
        end
      end
    end

    context "when volunteer hasn't logged in in the last 30 days" do
      it { is_expected.to contain_exactly(volunteer) }

      context "when volunteer is inactive" do
        let(:volunteer) { create(:volunteer, last_sign_in_at: 31.days.ago, active: false) }

        it { is_expected.to be_empty }
      end

      context "when volunteer has never logged in" do
        let(:volunteer) { create(:volunteer, last_sign_in_at: nil) }

        it { is_expected.to contain_exactly(volunteer) }
      end

      context "when volunteer has a recent case_contact" do
        let(:casa_case) { create(:casa_case, casa_org: supervisor.casa_org) }
        let!(:case_contact) { create(:case_contact, casa_case: casa_case, occurred_at: 31.days.ago, creator: volunteer, created_at: 29.days.ago) }

        it { is_expected.to be_empty }
      end
    end
  end

  describe "change to admin" do
    it "returns true if the change was successful" do
      expect(subject.change_to_admin!).to be_truthy
    end

    it "changes the supervisor to an admin" do
      subject.change_to_admin!

      user = User.find(subject.id) # subject.reload will cause RecordNotFound because it's looking in the wrong table
      expect(user).not_to be_supervisor
      expect(user).to be_casa_admin
    end
  end
end
