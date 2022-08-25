namespace :after_party do
  desc 'Deployment task: this task enable to show additional expenses'
  task enable_show_additional_expenses: :environment do
    puts "Running deploy task 'enable_show_additional_expenses'"
    FeatureFlagService.enable!(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)
    # Put your task implementation HERE.

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end