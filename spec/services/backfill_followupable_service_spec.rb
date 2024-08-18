require "rails_helper"

RSpec.describe BackfillFollowupableService do
  include ActiveJob::TestHelper

  let(:run_backfill) { described_class.new.fill_followup_id_and_type }

  after do
    clear_enqueued_jobs
  end

  describe "backfilling followup polymorphic columns" do
    let(:creator) { create(:user, display_name: "Craig") }
    let!(:followup) { create(:followup, creator: creator, note: "hello, this is the thing, ") }

    before do
      # immitate an instance from before polymorphic column change
      followup.update(followupable_id: nil, followupable_type: nil)
    end

    it "updates followupable_id and followupable_type correctly" do
      run_backfill
      followup.reload
      case_contact_id = followup.followupable_id

      expect(followup.followupable_id).to eq(case_contact_id)
      expect(followup.followupable_type).to eq("CaseContact")
    end

    context "when an error occurs during update" do
      before do
        allow_any_instance_of(Followup).to receive(:update_columns).and_raise(StandardError.new("Update failed"))
      end

      it "logs the error and notifies Bugsnag" do
        expect(Bugsnag).to receive(:notify).with(instance_of(StandardError))
        expect(Rails.logger).to receive(:error).with(/Failed to update Followup/)
        expect {
          run_backfill
        }.to_not change { followup.reload.followupable_id }
      end
    end
  end
end
