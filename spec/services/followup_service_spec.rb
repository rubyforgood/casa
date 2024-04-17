require "rails_helper"

RSpec.describe FollowupService do
  describe ".create_followup" do
    let(:case_contact) { create(:case_contact) }
    let(:creator) { create(:volunteer) }
    let(:note) { "This is a test note." }
    let(:notification_double) { double("FollowupNotification") }

    before do
      allow(FollowupNotification).to receive(:with).and_return(notification_double)
      allow(notification_double).to receive(:deliver)
    end

    it 'successfully creates a followup and sends notification' do
      expect {
        FollowupService.create_followup(case_contact, creator, note)
      }.to change(Followup, :count).by(1)

      followup = Followup.last
      expect(followup.note).to eq(note)
      expect(followup.creator).to eq(creator)
      expect(followup.followupable).to eq(case_contact)

      expect(FollowupNotification).to have_received(:with).with(
        followup: followup,
        created_by: creator
      )

      expect(notification_double).to have_received(:deliver)
    end

    context 'when followup fails to save' do
      before do
        allow_any_instance_of(Followup).to receive(:save).and_return(false)
      end

      it 'does not send a notification' do
        expect(FollowupService.create_followup(case_contact, creator, note)).to be_a_new(Followup)
        expect(FollowupNotification).not_to have_received(:with)
      end
    end
  end
end
