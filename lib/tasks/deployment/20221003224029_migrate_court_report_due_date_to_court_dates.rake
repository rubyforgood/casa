# frozen_string_literal: true

namespace :after_party do
  desc "Deployment task: migrate_court_report_due_date_to_court_dates"
  task migrate_court_report_due_date_to_court_dates: :environment do
    puts "Running deploy task 'migrate_court_report_due_date_to_court_dates'"

    # Put your task implementation HERE.
    casa_cases = CasaCase.all

    casa_cases.each do |casa_case|
      casa_case_last_court_date = casa_case.court_dates.max_by { |court_date| court_date.date }
      if !casa_case_last_court_date.nil?
        if casa_case_last_court_date.court_report_due_date.nil?
          casa_case_last_court_date.court_report_due_date = casa_case.court_report_due_date
          casa_case_last_court_date.save
        end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
