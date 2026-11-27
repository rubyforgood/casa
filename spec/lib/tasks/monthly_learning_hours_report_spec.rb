require "rails_helper"
require "rake"

RSpec.describe "send_learning_hour_reports rake task" do
  before(:all) do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  before(:each) do
    Rake::Task["send_learning_hour_reports"].reenable
    travel_to Date.new(2026, 1, 1)
  end

  subject(:run_task) { Rake::Task["send_learning_hour_reports"].invoke }

  let!(:active_admin_with_report) { create(:casa_admin, active: true, monthly_learning_hours_report: true) }
  let!(:active_admin_without_report) { create(:casa_admin, active: true, monthly_learning_hours_report: false) }
  let!(:inactive_admin_with_report) { create(:casa_admin, active: false, monthly_learning_hours_report: true) }

  let!(:active_supervisor_with_report) { create(:supervisor, active: true, monthly_learning_hours_report: true) }
  let!(:active_supervisor_without_report) { create(:supervisor, active: true, monthly_learning_hours_report: false) }
  let!(:inactive_supervisor_with_report) { create(:supervisor, active: false, monthly_learning_hours_report: true) }

  context "when today is the 1st of the month" do
    it "enqueues report emails only for active admins and supervisors with monthly reports enabled" do
      expect { run_task }
        .to have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(active_admin_with_report)
        .and have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(active_supervisor_with_report)
        .and have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).twice
    end

    it "does not enqueue report emails for inactive users or users with report disabled" do
      expect { run_task }
        .not_to have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(active_admin_without_report)

      Rake::Task["send_learning_hour_reports"].reenable
      expect { run_task }
        .not_to have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(inactive_admin_with_report)

      Rake::Task["send_learning_hour_reports"].reenable
      expect { run_task }
        .not_to have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(active_supervisor_without_report)

      Rake::Task["send_learning_hour_reports"].reenable
      expect { run_task }
        .not_to have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(inactive_supervisor_with_report)
    end
  end

  context "when today is not the 1st of the month" do
    before { travel_to Date.new(2026, 1, 2) }

    it "does not enqueue any report emails" do
      expect { run_task }
        .not_to have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email)
    end

    context "when FORCE=true" do
      before do
        stub_const("ENV", ENV.to_h.merge("FORCE" => "true"))
      end

      it "enqueues report emails for active admins and supervisors with monthly reports enabled" do
        expect { run_task }
          .to have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(active_admin_with_report)
          .and have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(active_supervisor_with_report)
          .and have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).twice
      end
    end
  end

  context "organization-aware timezone behavior and idempotency" do
    let(:kolkata_org) { create(:casa_org, time_zone: "Asia/Kolkata") }
    let(:honolulu_org) { create(:casa_org, time_zone: "Pacific/Honolulu") }

    let!(:kolkata_admin) { create(:casa_admin, casa_org: kolkata_org, active: true, monthly_learning_hours_report: true) }
    let!(:honolulu_admin) { create(:casa_admin, casa_org: honolulu_org, active: true, monthly_learning_hours_report: true) }

    # At 2026-01-01 02:00:00 UTC:
    # Kolkata (UTC+5:30) is 2026-01-01 07:30 (1st of the month)
    # Honolulu (UTC-10) is 2025-12-31 16:00 (last day of previous month)
    it "only enqueues emails for organizations where local date is the 1st of the month" do
      travel_to Time.utc(2026, 1, 1, 2, 0, 0) do
        expect { run_task }
          .to have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(kolkata_admin)

        Rake::Task["send_learning_hour_reports"].reenable
        expect { run_task }
          .not_to have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(honolulu_admin)
      end
    end

    it "is idempotent and does not enqueue duplicate emails when SentEmail record exists for the month" do
      travel_to Time.utc(2026, 1, 1, 2, 0, 0) do
        SentEmail.create!(
          casa_org: kolkata_org,
          user: kolkata_admin,
          sent_address: kolkata_admin.email,
          mailer_type: "LearningHoursMailer",
          category: "Learning hours report email"
        )

        expect { run_task }
          .not_to have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(kolkata_admin)
      end
    end

    it "rescues errors in one organization without blocking other organizations" do
      allow(kolkata_org).to receive(:with_time_zone).and_raise(StandardError, "Unexpected error")
      allow(CasaOrg).to receive(:find_each).and_yield(kolkata_org).and_yield(honolulu_org)

      travel_to Time.utc(2026, 1, 1, 22, 0, 0) do
        # At 22:00 UTC, Honolulu is 12:00 PM on Jan 1st
        expect { run_task }
          .to have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(honolulu_admin)
      end
    end

    context "early local 1st in positive UTC offset timezones (last day of previous month in UTC)" do
      let(:tokyo_org) { create(:casa_org, time_zone: "Asia/Tokyo") }
      let!(:tokyo_admin) { create(:casa_admin, casa_org: tokyo_org, active: true, monthly_learning_hours_report: true) }

      # Jan 1 01:00 AM JST is Dec 31 16:00 UTC
      it "deduplicates correctly across the UTC date boundary" do
        travel_to Time.utc(2025, 12, 31, 16, 0, 0) do
          expect { run_task }.to have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(tokyo_admin)
        end

        # Later on the 1st: 11:00 AM JST (02:00 UTC)
        travel_to Time.utc(2026, 1, 1, 2, 0, 0) do
          Rake::Task["send_learning_hour_reports"].reenable
          # SentEmail was created when processed
          SentEmail.create!(
            casa_org: tokyo_org,
            user: tokyo_admin,
            sent_address: tokyo_admin.email,
            mailer_type: "LearningHoursMailer",
            category: "Learning hours report email",
            created_at: Time.utc(2025, 12, 31, 16, 0, 0)
          )

          expect { run_task }.not_to have_enqueued_mail(LearningHoursMailer, :learning_hours_report_email).with(tokyo_admin)
        end
      end
    end
  end
end
