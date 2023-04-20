namespace :after_party do
  desc 'Deployment task: This will create a PreferenceSet for all users that are missing one'
  task backfill_user_prefernce_sets: :environment do
    puts "Running deploy task 'backfill_user_prefernce_sets'"

    # Put your task implementation HERE.
    User.includes(:preference_set).where(preference_sets: { id: nil }).find_in_batches(batch_size: 500) do |users|
      # NOTE: This should ideally be run in a background job.
      users.each(&:create_preference_set)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end