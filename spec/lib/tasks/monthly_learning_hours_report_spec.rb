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
end
