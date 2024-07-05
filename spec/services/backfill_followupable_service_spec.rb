require "rails_helper"

RSpec.describe BackfillFollowupableService do
  include ActiveJob::TestHelper

  let(:run_backfill) { described_class.new.fill_followup_id_and_type }

  after do
    clear_enqueued_jobs
  end

  describe "backfilling followup polymorphic columns" do
    let(:case_contact) { create(:case_contact) }
    let!(:followup) { create(:followup, :without_dual_writing, case_contact: case_contact) }

    it "updates followupable_id and followupable_type correctly" do
      expect { run_backfill }.to change { followup.reload.followupable_id }.from(nil).to(case_contact.id)
        .and change { followup.reload.followupable_type }.from(nil).to("CaseContact")
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
