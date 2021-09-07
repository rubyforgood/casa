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
    end
  end
end
