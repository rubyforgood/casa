require_relative "../data_post_processors/sms_notification_event_populator"

namespace :after_party do
  desc "Deployment task: populate_sms_notification_events"
  task populate_sms_notification_events: :environment do
    puts "Running deploy task 'populate_sms_notification_events'"

    SmsNotificationEventPopulator.populate

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
