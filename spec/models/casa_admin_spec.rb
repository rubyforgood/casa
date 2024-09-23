require "rails_helper"

RSpec.describe CasaAdmin, type: :model do
  let(:casa_admin) { build(:casa_admin) }

  describe "#deactivate" do
    it "deactivates the casa admin" do
      casa_admin.deactivate

      casa_admin.reload
      expect(casa_admin.active).to eq(false)
    end

    it "activates the casa admin" do
      casa_admin.active = false
      casa_admin.save
      casa_admin.activate

      casa_admin.reload
      expect(casa_admin.active).to eq(true)
    end
  end

  describe "#role" do
    subject(:admin) { build(:casa_admin) }

    it { expect(admin.role).to eq "Casa Admin" }
  end

  describe "invitation expiration" do
    let!(:mail) { casa_admin.invite! }
    let(:expiration_date) { I18n.l(casa_admin.invitation_due_at, format: :full, default: nil) }
    let(:two_weeks) { I18n.l(2.weeks.from_now, format: :full, default: nil) }

    it { expect(expiration_date).to eq two_weeks }
    it "expires invitation token after two weeks" do
      travel_to 2.weeks.from_now

      user = User.accept_invitation!(invitation_token: casa_admin.invitation_token)
      expect(user.errors.full_messages).to include("Invitation token is invalid")
      travel_back
    end
  end

  describe "change to supervisor" do
    subject(:admin) { create(:casa_admin) }

    it "returns true if the change was successful" do
      expect(subject.change_to_supervisor!).to be_truthy
    end

    it "changes the supervisor to an admin" do
      subject.change_to_supervisor!

      user = User.find(subject.id) # subject.reload will cause RecordNotFound because it's looking in the wrong table
      expect(user).not_to be_casa_admin
      expect(user).to be_supervisor
    end
  end
end
