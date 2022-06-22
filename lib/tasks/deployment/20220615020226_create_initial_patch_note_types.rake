namespace :after_party do
  desc "Deployment task: create_initial_patch_note_types"
  task create_initial_patch_note_types: :environment do
    puts "Running deploy task 'create_initial_patch_note_types'"

    load(Rails.root.join("db", "seeds", "patch_note_type_data.rb"))

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
