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

    it "#send_reminders creates the reminders" do
      #ActiveJob::Base.queue_adapter = :test
      pp eligible_case1.casa_case
      pp eligible_case2.casa_case
      #allow(EmancipationChecklistReminderNotification).to receive(:deliver)
      expect_any_instance_of(EmancipationChecklistReminderNotification).to receive(:deliver)
      task.send_reminders
      #expect { task.send_reminders }.to have_enqueued_job.twice
    end
  end
end
