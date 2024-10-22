require_relative "../data_post_processors/case_contact_populator"

namespace :after_party do
  desc "Deployment task: populate_case_contact_contact_type"
  task populate_case_contact_contact_type: :environment do
    puts "Running deploy task 'populate_case_contact_contact_type'" unless Rails.env.test?

    CaseContactPopulator.populate

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
