namespace :after_party do
  desc "Deployment task: populate_missing_display_names"
  task populate_missing_display_names: :environment do
    puts "Running deploy task 'populate_missing_display_names'" unless Rails.env.test?

    User.find_each do |user|
      if user.display_name.blank?
        user.display_name = Faker::Name.name
        user.save(validate: false)
      end
    end
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
