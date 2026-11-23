require "rails_helper"
require "rake"

RSpec.describe "youth_birthday_reminder rake task" do
  before(:all) do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  before(:each) do
    Rake::Task["youth_birthday_reminder"].reenable
    travel_to Date.new(2026, 1, 15)
  end

  subject(:run_task) { Rake::Task["youth_birthday_reminder"].invoke }

  # birthday_next_month matches on the birth MONTH; the youth's birth year must be
  # in the past (a future birth date is rejected by the model), so use a past year
  # with next calendar month.
  let!(:casa_case) { create(:casa_case, birth_month_year_youth: Date.new(2012, 2, 15)) }

  context "when today is the 15th of the month" do
    context "when a birthday-next-month case has no active assignment" do
      it "does not raise" do
        expect { run_task }.not_to raise_error
      end

      it "creates no notification" do
        expect { run_task }.not_to change(Noticed::Notification, :count)
      end
    end

    context "when a birthday-next-month case has an active assignment" do
      let!(:assignment) { create(:case_assignment, casa_case: casa_case, active: true) }

      it "notifies the assigned volunteer" do
        expect { run_task }.to change(Noticed::Notification, :count).by(1)
      end
    end

    context "when a birthday-next-month case has multiple active assignments" do
      let!(:assignments) { create_list(:case_assignment, 2, casa_case: casa_case, active: true) }

      it "notifies each active volunteer" do
        expect { run_task }.to change(Noticed::Notification, :count).by(2)
      end
    end

    context "when a case has both an active and an inactive assignment" do
      let!(:active_assignment) { create(:case_assignment, casa_case: casa_case, active: true) }
      let!(:inactive_assignment) { create(:case_assignment, casa_case: casa_case, active: false) }

      it "notifies only the active volunteer" do
        expect { run_task }.to change(Noticed::Notification, :count).by(1)
      end
    end

    context "when the only assignment is inactive" do
      let!(:assignment) { create(:case_assignment, casa_case: casa_case, active: false) }

      it "does not notify" do
        expect { run_task }.not_to change(Noticed::Notification, :count)
      end
    end
  end

  context "when today is not the 15th of the month" do
    before { travel_to Date.new(2026, 1, 14) }

    let!(:assignment) { create(:case_assignment, casa_case: casa_case, active: true) }

    it "does not notify" do
      expect { run_task }.not_to change(Noticed::Notification, :count)
    end

    context "when FORCE=true" do
      before do
        stub_const("ENV", ENV.to_h.merge("FORCE" => "true"))
      end

      it "notifies the assigned volunteer" do
        expect { run_task }.to change(Noticed::Notification, :count).by(1)
      end
    end
  end

  context "organization-aware timezone behavior and idempotency" do
    let(:kolkata_org) { create(:casa_org, time_zone: "Asia/Kolkata") }
    let(:honolulu_org) { create(:casa_org, time_zone: "Pacific/Honolulu") }

    let(:kolkata_case) { create(:casa_case, casa_org: kolkata_org, birth_month_year_youth: Date.new(2012, 2, 15)) }
    let(:kolkata_volunteer) { create(:volunteer, casa_org: kolkata_org) }
    let!(:kolkata_assignment) { create(:case_assignment, casa_case: kolkata_case, volunteer: kolkata_volunteer, active: true) }

    let(:honolulu_case) { create(:casa_case, casa_org: honolulu_org, birth_month_year_youth: Date.new(2012, 2, 15)) }
    let(:honolulu_volunteer) { create(:volunteer, casa_org: honolulu_org) }
    let!(:honolulu_assignment) { create(:case_assignment, casa_case: honolulu_case, volunteer: honolulu_volunteer, active: true) }

    # At 2026-01-15 02:00:00 UTC:
    # Kolkata is 2026-01-15 07:30 (15th of the month)
    # Honolulu is 2026-01-14 16:00 (14th of the month)
    it "only notifies volunteers in organizations where local date is the 15th" do
      travel_to Time.utc(2026, 1, 15, 2, 0, 0) do
        expect { run_task }.to change { kolkata_volunteer.notifications.count }.by(1)
          .and not_change { honolulu_volunteer.notifications.count }
      end
    end

    it "is idempotent and does not send duplicate notifications when run repeatedly" do
      travel_to Time.utc(2026, 1, 15, 2, 0, 0) do
        run_task
        Rake::Task["youth_birthday_reminder"].reenable
        expect { run_task }.not_to change(Noticed::Notification, :count)
      end
    end

    it "rescues errors in one organization without preventing notifications for others" do
      allow(kolkata_org).to receive(:with_time_zone).and_raise(StandardError, "Unexpected error")
      allow(CasaOrg).to receive(:find_each).and_yield(kolkata_org).and_yield(honolulu_org)

      travel_to Time.utc(2026, 1, 15, 22, 0, 0) do
        # At 22:00 UTC, Honolulu is 12:00 PM on Jan 15th
        expect { run_task }.not_to raise_error
        expect(honolulu_volunteer.notifications.count).to eq(1)
      end
    end

    context "early local 15th in positive UTC offset timezones (14th in UTC)" do
      let(:tokyo_org) { create(:casa_org, time_zone: "Asia/Tokyo") }
      let(:tokyo_case) { create(:casa_case, casa_org: tokyo_org, birth_month_year_youth: Date.new(2012, 2, 15)) }
      let(:tokyo_volunteer) { create(:volunteer, casa_org: tokyo_org) }
      let!(:tokyo_assignment) { create(:case_assignment, casa_case: tokyo_case, volunteer: tokyo_volunteer, active: true) }

      # Jan 15 01:00 AM JST is Jan 14 16:00 UTC
      it "deduplicates correctly across the UTC date boundary" do
        travel_to Time.utc(2026, 1, 14, 16, 0, 0) do
          expect { run_task }.to change { tokyo_volunteer.notifications.count }.by(1)
        end

        # Later on the 15th: 11:00 AM JST (02:00 UTC)
        travel_to Time.utc(2026, 1, 15, 2, 0, 0) do
          run_task
          Rake::Task["youth_birthday_reminder"].reenable
          expect { run_task }.not_to change(Noticed::Notification, :count)
        end
      end
    end
  end
end
