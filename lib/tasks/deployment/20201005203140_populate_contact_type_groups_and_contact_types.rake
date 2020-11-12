require_relative "../data_post_processors/contact_type_populator"

namespace :after_party do
  desc "Deployment task: populate_contact_type_groups_and_contact_types"
  task populate_contact_type_groups_and_contact_types: :environment do
    puts "Running deploy task 'populate_contact_type_groups_and_contact_types'" unless Rails.env.test?
    ContactTypePopulator.populate
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
