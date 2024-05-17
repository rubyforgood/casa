require "rails_helper"

RSpec.describe "CaseContacts::FollowupsController", type: :request do
  let(:volunteer) { create(:volunteer) }
  let(:case_contact) { create(:case_contact) }

  describe "POST /create" do
    let(:notification_double) { double("FollowupNotifier") }
    let(:params) { {note: "Hello, world!"} }

    subject(:request) do
      post case_contact_followups_path(case_contact), params: params

      response
    end

    before do
      sign_in volunteer
      allow(FollowupNotifier).to receive(:with).and_return(notification_double)
      allow(notification_double).to receive(:deliver)
    end

    it "creates a followup", :aggregate_failures do
      expect { request }.to change(Followup, :count).by(1)

      followup = Followup.last
      expect(followup.note).to eq "Hello, world!"
    end

    it "sends a Followup Notification to case contact creator" do
      request
      followup = Followup.last
      expect(FollowupNotifier).to(
        have_received(:with).once.with(followup: followup, created_by: volunteer)
      )
      expect(notification_double).to have_received(:deliver).once.with(case_contact.creator)
    end

    context "with invalid case_contact" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { post case_contact_followups_path(444444) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "PATCH /resolve" do
    let(:notification_double) { double("FollowupResolvedNotifier") }

    before do
      sign_in volunteer
      allow(FollowupResolvedNotifier).to receive(:with).and_return(notification_double)
      allow(notification_double).to receive(:deliver)
    end

    context "followup exists" do
      let(:followup) { create(:followup, case_contact: case_contact, creator: volunteer) }

      subject(:request) do
        patch resolve_followup_path(followup)

        response
      end

      it "marks it as :resolved" do
        followup
        expect { request }.to change { followup.reload.resolved? }.from(false).to(true)
      end

      it "does not send Followup Notification" do
        followup
        expect(FollowupResolvedNotifier).not_to receive(:with)
        expect { request }.to change { followup.reload.resolved? }.from(false).to(true)
      end

      context "when who resolves the followup is not the followup's creator" do
        let(:followup) { create(:followup, case_contact: case_contact) }

        it "sends a Followup Notification to the creator" do
          request
          expect(FollowupResolvedNotifier).to(
            have_received(:with).once.with(followup: followup, created_by: volunteer)
          )
          expect(notification_double).to have_received(:deliver).once.with(followup.creator)
        end
      end
    end

    context "followup doesn't exists" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { patch resolve_followup_path(444444) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
