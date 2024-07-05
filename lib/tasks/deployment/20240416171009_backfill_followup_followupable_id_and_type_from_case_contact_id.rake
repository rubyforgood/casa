namespace :after_party do
  desc "Deployment task: Deployment task: backfill Followup polymorephic columns (followupable_id and followupable_type) from case_contact_id"
  task backfill_followup_followupable_id_and_type_from_case_contact_id: :environment do
    puts "Running deploy task 'backfill_followup_followupable_id_and_type_from_case_contact_id'"
    BackfillFollowupableService.new.fill_followup_id_and_type

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
