namespace :after_party do
  desc "Deployment task: Create default standard court orders for every CASA org"
  task create_default_standard_court_orders: :environment do
    puts "Running deploy task 'create_default_standard_court_orders'"

    # Put your task implementation HERE.
    Deployment::CreateDefaultStandardCourtOrdersService.new.create_defaults

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
