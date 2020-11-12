namespace :after_party do
  desc "Deployment task: Backfill court_report_submitted_at and court_report_status"
  task backfill_court_report_submitted_at: :environment do
    puts "Running deploy task 'backfill_court_report_submitted_at'" unless Rails.env.test?

    CasaCase.where(court_report_submitted: true).in_batches.update_all(court_report_status: :submitted,
                                                                       court_report_submitted_at: Time.current)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
