namespace :after_party do
  desc "Deployment task: set metadata for status started to every CaseContact that had status metadata"
  task backfill_case_contact_started_metadata: :environment do
    puts "Running deploy task 'backfill_case_contact_started_metadata'"

    # Put your task implementation HERE.
    Deployment::BackfillCaseContactStartedMetadataService.new.backfill_metadata

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
