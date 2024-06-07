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
      expect { task.send_reminders }.to change { EmancipationChecklistReminderNotifier.count }.by(2)
    end

    it "#send_reminders also sends the notifications" do
      instance = instance_double(EmancipationChecklistReminderNotifier)
      expect(EmancipationChecklistReminderNotifier).to receive(:new) { instance }.twice
      expect(instance).to receive(:deliver).twice
      task.send_reminders
    end
  end
end
