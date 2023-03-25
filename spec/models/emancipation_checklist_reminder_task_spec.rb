require "rails_helper"

RSpec.describe EmancipationChecklistReminderTask, type: :model do
  let!(:eligible_case1) { create(:case_assignment) }
  let!(:eligible_case2) { create(:case_assignment) }
  let!(:ineligible_case1) { create(:case_assignment, pre_transition: true) }
  let!(:inactive_case) { create(:case_assignment, :inactive) }
  subject(:task) { described_class.new }

  context "with only two eligible cases" do
    it "#initialize correctly captures the eligible cases" do
      expect(CasaCase.count).to eq(4)
      expect(task.cases).to_not be_empty
      expect(task.cases.length).to eq(2)
    end

    it "#send_reminders creates the reminders and calls deliver" do
      ActiveJob::Base.queue_adapter = :test
      expect { task.send_reminders }
        .to change { Notification.count }.by(2)
        .and have_enqueued_job.exactly(:twice)
    end
  end
end
