require "rails_helper"

RSpec.describe VolunteerBirthdayReminderService do
  include ActiveJob::TestHelper

  let(:send_reminders) { described_class.new.send_reminders }
  let(:now) { Date.new(2022, 10, 15) }
  let(:this_month) { now.month }
  let(:this_month_15th) { Date.new(now.year, now.month, 15) }
  let(:next_month) { Date.new(1988, this_month + 1, 1) }
  let(:not_next_month) { Date.new(1998, this_month - 1, 1) }

  before do
    travel_to now
  end

  after do
    clear_enqueued_jobs
  end

  context "there is a volunteer with a birthday next month" do
    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: next_month)
    end

    it "creates a notification" do
      expect { send_reminders }.to change { volunteer.supervisor.notifications.count }.by(1)
    end
  end

  context "there are multiple volunteers with birthdays next month" do
    let(:supervisor) { create(:supervisor) }
    let!(:volunteer) do
      create_list(:volunteer, 4, :with_assigned_supervisor, date_of_birth: next_month, supervisor: supervisor)
    end

    it "creates multiple notifications" do
      expect { send_reminders }.to change { Noticed::Notification.count }.by(4)
    end
  end

  context "there is an unsupervised volunteer with a birthday next month" do
    let!(:volunteer) do
      create(:volunteer, date_of_birth: next_month)
    end

    it "does not create a notification" do
      expect { send_reminders }.not_to change { Noticed::Notification.count }
    end
  end

  context "there is a volunteer with no date_of_birth" do
    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: nil)
    end

    it "does not create a notification" do
      expect { send_reminders }.not_to change { volunteer.supervisor.notifications.count }
    end
  end

  context "there is a volunteer with a birthday that is not next month" do
    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: not_next_month)
    end

    it "does not create a notification" do
      expect { send_reminders }.not_to change { volunteer.supervisor.notifications.count }
    end
  end

  context "when today is the 15th" do
    before { travel_to(this_month_15th) }

    let!(:volunteer) do
      create(:volunteer, :with_assigned_supervisor, date_of_birth: next_month)
    end

    it "runs the rake task" do
      expect { send_reminders }.to change { volunteer.supervisor.notifications.count }.by(1)
    end
  end

  context "when today is not the 15th" do
    before { travel_to(this_month_15th + 2.days) }

    it "skips the rake task" do
      expect { send_reminders }.not_to change { Noticed::Notification.count }
    end
  end

  context "organization-aware timezone behavior and idempotency" do
    let(:kolkata_org) { create(:casa_org, time_zone: "Asia/Kolkata") }
    let(:honolulu_org) { create(:casa_org, time_zone: "Pacific/Honolulu") }

    let(:kolkata_supervisor) { create(:supervisor, casa_org: kolkata_org) }
    let!(:kolkata_volunteer) do
      create(:volunteer, :with_assigned_supervisor, casa_org: kolkata_org, supervisor: kolkata_supervisor, date_of_birth: Date.new(1990, 11, 20))
    end

    let(:honolulu_supervisor) { create(:supervisor, casa_org: honolulu_org) }
    let!(:honolulu_volunteer) do
      create(:volunteer, :with_assigned_supervisor, casa_org: honolulu_org, supervisor: honolulu_supervisor, date_of_birth: Date.new(1992, 11, 22))
    end

    # At 2022-10-15 02:00:00 UTC:
    # Kolkata (UTC+5:30) is 2022-10-15 07:30 (15th of the month)
    # Honolulu (UTC-10) is 2022-10-14 16:00 (14th of the month)
    it "only notifies supervisors in organizations where local date is the 15th" do
      travel_to Time.utc(2022, 10, 15, 2, 0, 0) do
        expect { send_reminders }.to change { kolkata_supervisor.notifications.count }.by(1)
          .and not_change { honolulu_supervisor.notifications.count }
      end
    end

    it "is idempotent and does not send duplicate notifications when run repeatedly" do
      travel_to Time.utc(2022, 10, 15, 2, 0, 0) do
        described_class.new.send_reminders
        expect { described_class.new.send_reminders }.not_to change { Noticed::Notification.count }
      end
    end

    it "supports scoping to a specific organization" do
      travel_to Time.utc(2022, 10, 15, 2, 0, 0) do
        expect { described_class.new(kolkata_org).send_reminders }.to change { kolkata_supervisor.notifications.count }.by(1)
        expect(honolulu_supervisor.notifications.count).to eq(0)
      end
    end

    it "rescues errors in one organization without blocking other organizations" do
      allow(kolkata_org).to receive(:with_time_zone).and_raise(StandardError, "Unexpected error")
      allow(CasaOrg).to receive(:find_each).and_yield(kolkata_org).and_yield(honolulu_org)

      travel_to Time.utc(2022, 10, 15, 22, 0, 0) do
        # At 22:00 UTC, Honolulu is 12:00 PM on Oct 15th
        expect { described_class.new.send_reminders }.not_to raise_error
        expect(honolulu_supervisor.notifications.count).to eq(1)
      end
    end

    context "early local 15th in positive UTC offset timezones (14th in UTC)" do
      let(:tokyo_org) { create(:casa_org, time_zone: "Asia/Tokyo") }
      let(:tokyo_supervisor) { create(:supervisor, casa_org: tokyo_org) }
      let!(:tokyo_volunteer) do
        create(:volunteer, :with_assigned_supervisor, casa_org: tokyo_org, supervisor: tokyo_supervisor, date_of_birth: Date.new(1990, 11, 20))
      end

      # Oct 15 01:00 AM JST is Oct 14 16:00 UTC
      it "deduplicates correctly across the UTC date boundary" do
        travel_to Time.utc(2022, 10, 14, 16, 0, 0) do
          expect { described_class.new(tokyo_org).send_reminders }.to change { tokyo_supervisor.notifications.count }.by(1)
        end

        # Later on the 15th: 11:00 AM JST (02:00 UTC)
        travel_to Time.utc(2022, 10, 15, 2, 0, 0) do
          expect { described_class.new(tokyo_org).send_reminders }.not_to change { tokyo_supervisor.notifications.count }
        end
      end
    end
  end
end
