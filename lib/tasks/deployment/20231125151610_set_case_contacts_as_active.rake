namespace :after_party do
  desc "Deployment task: set_case_contacts_as_active"
  task set_case_contacts_as_active: :environment do
    puts "Running deploy task 'set_case_contacts_as_active'"

    CaseContact.all.each do |cc|
      begin
        cc.update!(status: "active", draft_case_ids: [cc.casa_case_id])
      rescue => e
        p e
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
        .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
