# Temporarily define the Notification model to access the old table
class Notification < ActiveRecord::Base
  self.inheritance_column = nil
end

namespace :after_party do
  desc "Deployment task: Migrates existing notifications to new tables for noticed gem v2.x"
  task migrate_notifications: :environment do
    puts "Running deploy task 'migrate_notifications'"

    # Migrate each record to the new tables
    Notification.find_each do |notification|
      attributes = notification.attributes.slice("type", "created_at", "updated_at").with_indifferent_access

      attributes[:type] = attributes[:type].sub("Notification", "Notifier")

      attributes[:params] = Noticed::Coder.load(notification.params)
      attributes[:params] = {} if attributes[:params].try(:has_key?, "noticed_error") # Skip invalid records

      attributes[:notifications_attributes] = [{
        type: "#{attributes[:type]}::Notification",
        recipient_type: notification.recipient_type,
        recipient_id: notification.recipient_id,
        read_at: notification.read_at,
        seen_at: notification.read_at,
        created_at: notification.created_at,
        updated_at: notification.updated_at
      }]
      Noticed::Event.create!(attributes)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
