namespace :after_party do
  desc "Deployment task: populate_new_api_and_refresh_token"
  task populate_new_api_and_refresh_token: :environment do
    puts "Running deploy task 'populate_new_api_and_refresh_token'"

    # Put your task implementation HERE.
    User.find_each do |user|
      user.update(receive_sms_notifications: false) if user.phone_number.blank?
      user.api_credential || user.create_api_credential
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
