# frozen_string_literal: true

namespace :after_party do
  desc "Deployment task: migrate_court_report_due_date_to_court_dates"
  task migrate_court_report_due_date_to_court_dates: :environment do
    puts "task deleted because it uses the removed field casa_case.court_report_due_date"
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
