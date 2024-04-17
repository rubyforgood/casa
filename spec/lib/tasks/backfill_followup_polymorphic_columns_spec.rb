require "rails_helper"
require "rake"

RSpec.describe "after_party:backfill_followup_followupable_id_and_type_from_case_contact_id", type: :task do
  before :all do
    Rake.application.rake_require "tasks/deployment/20240416171009_backfill_followup_followupable_id_and_type_from_case_contact_id"
    Rake::Task.define_task(:environment)
  end

  let(:task_name) { "after_party:backfill_followup_followupable_id_and_type_from_case_contact_id" }

  after(:each)  do
    Rake::Task[task_name].reenable # Ensures the task can be run multiple times
  end

  describe "backfilling followup polymorphic columns" do
    let(:case_contact) { create(:case_contact) }
    let!(:followup) { create(:followup, :without_dual_writing, case_contact: case_contact) }

    it "updates followupable_id and followupable_type correctly" do
      expect {
        Rake::Task[task_name].invoke
      }.to change { followup.reload.followupable_id }.from(nil).to(case_contact.id)
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
          Rake::Task[task_name].invoke
        }.to_not change { followup.reload.followupable_id }
      end
    end
  end
end
