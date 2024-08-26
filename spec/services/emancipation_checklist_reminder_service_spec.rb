require "rails_helper"

RSpec.describe EmancipationChecklistReminderService do
  include ActiveJob::TestHelper

  let(:send_reminders) { described_class.new.send_reminders }

  before do
    travel_to Date.new(2022, 10, 1)
  end

  after do
    travel_back
    clear_enqueued_jobs
  end

  context "with only two eligible cases" do
    subject(:task) { described_class.new }
    let!(:eligible_case1) { create(:case_assignment) }
    let!(:eligible_case2) { create(:case_assignment) }
    let!(:ineligible_case1) { create(:case_assignment, pre_transition: true) }
    let!(:inactive_case) { create(:case_assignment, :inactive) }

    it "#initialize correctly captures the eligible cases" do
      expect(CasaCase.count).to eq(4)
      expect(task.cases).to_not be_empty
      expect(task.cases.length).to eq(2)
    end
  end

  context "volunteer with transition age youth case" do
    let!(:casa_case) { create(:casa_case, :with_one_case_assignment) }

    it "should send notification" do
      expect { send_reminders }.to change { casa_case.case_assignments.first.volunteer.notifications.count }.by(1)
    end
  end

  context "volunteer with multiple transition age youth cases" do
    let!(:volunteer) { create(:volunteer, :with_casa_cases) }

    it "sends notification for each case" do
      expect { send_reminders }.to change { volunteer.notifications.count }.by(2)
    end
  end

  context "volunteer without transition age youth case" do
    let!(:casa_case) { create(:casa_case, :with_one_case_assignment, birth_month_year_youth: 13.years.ago) }

    it "should not send notification" do
      expect { send_reminders }.not_to change { casa_case.case_assignments.first.volunteer.notifications.count }
    end
  end

  context "when the case assignment is inactive" do
    let!(:case_assignment) { create(:case_assignment, :inactive) }

    it "should not send notification" do
      expect { send_reminders }.not_to change { case_assignment.volunteer.notifications.count }
    end
  end

  context "when there are no case assignments" do
    it "does not raise error" do
      expect { send_reminders }.not_to raise_error
    end
  end
end
