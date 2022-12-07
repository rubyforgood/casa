namespace :after_party do
  desc "Deployment task: create_initial_patch_note_groups"
  task create_initial_patch_note_groups: :environment do
    puts "Running deploy task 'create_initial_patch_note_groups'"

    PatchNote.destroy_all
    PatchNoteGroup.destroy_all
    load(Rails.root.join("db", "seeds", "patch_note_group_data.rb"))

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
