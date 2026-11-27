require "rails_helper"

RSpec.describe EmancipationChecklistReminderService do
  include ActiveJob::TestHelper

  let(:send_reminders) { described_class.new.send_reminders }

  before do
    travel_to Date.new(2022, 10, 1)
  end

  after do
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
      expect(task.cases).not_to be_empty
      expect(task.cases.length).to eq(2)
    end
  end

  context "volunteer with transition age youth case" do
    let!(:casa_case) { create(:casa_case, :with_one_case_assignment) }

    it "sends notification" do
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

    it "does not send notification" do
      expect { send_reminders }.not_to change { casa_case.case_assignments.first.volunteer.notifications.count }
    end
  end

  context "when the case assignment is inactive" do
    let!(:case_assignment) { create(:case_assignment, :inactive) }

    it "does not send notification" do
      expect { send_reminders }.not_to change { case_assignment.volunteer.notifications.count }
    end
  end

  context "when there are no case assignments" do
    it "does not raise error" do
      expect { send_reminders }.not_to raise_error
    end
  end

  context "organization-aware timezone behavior and idempotency" do
    let(:kolkata_org) { create(:casa_org, time_zone: "Asia/Kolkata") }
    let(:honolulu_org) { create(:casa_org, time_zone: "Pacific/Honolulu") }

    let(:kolkata_case) { create(:casa_case, casa_org: kolkata_org) }
    let(:kolkata_volunteer) { create(:volunteer, casa_org: kolkata_org) }
    let!(:kolkata_assignment) { create(:case_assignment, casa_case: kolkata_case, volunteer: kolkata_volunteer, active: true) }

    let(:honolulu_case) { create(:casa_case, casa_org: honolulu_org) }
    let(:honolulu_volunteer) { create(:volunteer, casa_org: honolulu_org) }
    let!(:honolulu_assignment) { create(:case_assignment, casa_case: honolulu_case, volunteer: honolulu_volunteer, active: true) }

    # At 2022-10-01 02:00:00 UTC:
    # Kolkata (UTC+5:30) is 2022-10-01 07:30 (1st of the month)
    # Honolulu (UTC-10) is 2022-09-30 16:00 (last day of previous month)
    it "only notifies volunteers in organizations where local date is the 1st of the month" do
      travel_to Time.utc(2022, 10, 1, 2, 0, 0) do
        expect { send_reminders }.to change { kolkata_volunteer.notifications.count }.by(1)
          .and not_change { honolulu_volunteer.notifications.count }
      end
    end

    it "is idempotent and does not send duplicate notifications when run repeatedly" do
      travel_to Time.utc(2022, 10, 1, 2, 0, 0) do
        described_class.new.send_reminders
        expect { described_class.new.send_reminders }.not_to change { Noticed::Notification.count }
      end
    end

    it "supports scoping to a specific organization" do
      travel_to Time.utc(2022, 10, 1, 2, 0, 0) do
        expect { described_class.new(kolkata_org).send_reminders }.to change { kolkata_volunteer.notifications.count }.by(1)
        expect(honolulu_volunteer.notifications.count).to eq(0)
      end
    end

    it "rescues errors in one organization without blocking other organizations" do
      allow(kolkata_org).to receive(:with_time_zone).and_raise(StandardError, "Unexpected error")
      allow(CasaOrg).to receive(:find_each).and_yield(kolkata_org).and_yield(honolulu_org)

      travel_to Time.utc(2022, 10, 1, 22, 0, 0) do
        # At 22:00 UTC, Honolulu is 12:00 PM on Oct 1st
        expect { described_class.new.send_reminders }.not_to raise_error
        expect(honolulu_volunteer.notifications.count).to eq(1)
      end
    end

    context "early local 1st in positive UTC offset timezones (last day of previous month in UTC)" do
      let(:tokyo_org) { create(:casa_org, time_zone: "Asia/Tokyo") }
      let(:tokyo_case) { create(:casa_case, casa_org: tokyo_org) }
      let(:tokyo_volunteer) { create(:volunteer, casa_org: tokyo_org) }
      let!(:tokyo_assignment) { create(:case_assignment, casa_case: tokyo_case, volunteer: tokyo_volunteer, active: true) }

      # Oct 1 01:00 AM JST is Sept 30 16:00 UTC
      it "deduplicates correctly across the UTC date boundary" do
        travel_to Time.utc(2022, 9, 30, 16, 0, 0) do
          expect { described_class.new(tokyo_org).send_reminders }.to change { tokyo_volunteer.notifications.count }.by(1)
        end

        # Later on the 1st: 11:00 AM JST (02:00 UTC)
        travel_to Time.utc(2022, 10, 1, 2, 0, 0) do
          expect { described_class.new(tokyo_org).send_reminders }.not_to change { tokyo_volunteer.notifications.count }
        end
      end
    end
  end
end
