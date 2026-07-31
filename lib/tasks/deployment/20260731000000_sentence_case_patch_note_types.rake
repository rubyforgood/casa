namespace :after_party do
  desc "Deployment task: rename the app-shipped patch note types to sentence case"
  task sentence_case_patch_note_types: :environment do
    puts "Running deploy task 'sentence_case_patch_note_types'"

    # db/seeds/patch_note_type_data.rb is sentence-cased now (design system), but the seeds use
    # first_or_create by name, so an existing database keeps "Coming Up" / "What's New?" and a reseed
    # would ADD the sentence-case rows beside them. Rename in place instead.
    #
    # Only case-variants of the shipped defaults are touched -- a name an all-casa admin typed
    # themselves never matches, so free-form data is left alone (same rule as the contact-type task).
    renamed = 0
    {"Coming up" => "coming up", "What's new?" => "what's new?"}.each do |target, downcased|
      renamed += PatchNoteType
        .where("LOWER(name) = ? AND name <> ?", downcased, target)
        .update_all(name: target)
    end

    puts "  renamed #{renamed} patch note type(s)"

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
