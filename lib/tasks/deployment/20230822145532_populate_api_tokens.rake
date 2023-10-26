namespace :after_party do
  desc "Deployment task: populate_api_tokens"
  task populate_api_tokens: :environment do
    puts "Running deploy task 'populate_api_tokens'" unless Rails.env.test?

    # Put your task implementation HERE.
    User.where(token: nil).each(&:regenerate_token)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
