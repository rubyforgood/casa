namespace :after_party do
  desc 'Deployment task: add_confrimation_to_existing_users'
  task add_confrimation_to_existing_users: :environment do
    puts "Running deploy task 'add_confrimation_to_existing_users'"

    User.update_all confirmed_at: DateTime.now

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end