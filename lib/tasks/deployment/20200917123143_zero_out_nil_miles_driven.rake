namespace :after_party do
  desc 'Deployment task: database_update_nil_miles_driven_to_be_zero'
  task zero_out_nil_miles_driven: :environment do
    puts "Running deploy task 'zero_out_nil_miles_driven'"

    # Put your task implementation HERE.
    contacts = CaseContact.where(miles_driven: nil)
    contacts.each do |contact|
        contact.miles_driven = 0
        contact.save
    end
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end