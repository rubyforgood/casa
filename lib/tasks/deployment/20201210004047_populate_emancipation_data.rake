namespace :after_party do
  desc "Deployment task: populate_emancipation_data"
  task populate_emancipation_data: :environment do
    puts "Running deploy task 'populate_emancipation_data'"

    load(Rails.root.join("db", "seeds", "emancipation_data.rb"))

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
