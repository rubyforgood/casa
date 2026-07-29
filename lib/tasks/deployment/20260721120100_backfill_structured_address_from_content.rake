namespace :after_party do
  desc "Deployment task: seed structured address line_1 from the legacy single-line content"
  task backfill_structured_address_from_content: :environment do
    puts "Running deploy task 'backfill_structured_address_from_content'"

    # Existing addresses only have the free-text `content`. We can't reliably split a single
    # string into line/city/state/zip, so we drop the whole value into line_1 (no data loss);
    # the composed `content` for a line_1-only address is identical, so readers are unaffected.
    # column-to-column UPDATE, skips callbacks so it won't recompose content.
    Address
      .where.not(content: [nil, ""])
      .where(line_1: [nil, ""], line_2: [nil, ""], city: [nil, ""], state: [nil, ""], zip: [nil, ""])
      .in_batches
      .update_all("line_1 = content")

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
