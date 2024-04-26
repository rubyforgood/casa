namespace :after_party do
  desc "Deployment task: Deployment task: backfill Followup polymorephic columns (followupable_id and followupable_type) from case_contact_id"
  task backfill_followup_followupable_id_and_type_from_case_contact_id: :environment do
    puts "Running deploy task 'backfill_followup_followupable_id_and_type_from_case_contact_id'"

    Followup.find_each(batch_size: 500) do |followup|
      followup.update_columns(
        followupable_id: followup.case_contact_id,
        followupable_type: "CaseContact"
      )
    rescue => e
      Bugsnag.notify(e) do |event|
        event.add_metadata(:followup, {
          followup_id: followup.id,
          case_contact_id: followup.case_contact_id
        })
      end
      Rails.logger.error "Failed to update Followup ##{followup.id}: #{e.message}"
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
