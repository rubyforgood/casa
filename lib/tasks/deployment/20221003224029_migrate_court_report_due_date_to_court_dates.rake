# frozen_string_literal: true

namespace :after_party do
  desc "Deployment task: migrate_court_report_due_date_to_court_dates"
  task migrate_court_report_due_date_to_court_dates: :environment do
    puts "Running deploy task 'migrate_court_report_due_date_to_court_dates'"

    # Put your task implementation HERE.
    MigrateCourtReportDueDateService.new.run!

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
