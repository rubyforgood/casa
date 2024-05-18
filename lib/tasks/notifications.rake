# Temporarily define the Notification model to access the old table
# class Notification < ActiveRecord::Base
#   self.inheritance_column = nil
# end

namespace :notifications do
  desc "Migrates existing notifications to new tables for noticed gem v2.x"
  task migrate: :environment do
    puts "Migrating notification data..."
    start = Time.now

    # Migrate each record to the new tables
    Notification.find_each do |notification|
      attributes = notification.attributes.slice("type", "created_at", "updated_at").with_indifferent_access

      attributes[:type] = attributes[:type].sub("EmancipationChecklistReminderNotification", "EmancipationChecklistReminderNotification")
      attributes[:type] = attributes[:type].sub("FollowupNotification", "FollowupNotification")
      attributes[:type] = attributes[:type].sub("FollowupResolvedNotification", "FollowupResolvedNotification")
      attributes[:type] = attributes[:type].sub("ReimbursementCompleteNotification", "ReimbursementCompleteNotification")
      attributes[:type] = attributes[:type].sub("VolunteerBirthdayNotification", "VolunteerBirthdayNotification")
      attributes[:type] = attributes[:type].sub("YouthBirthdayNotification", "YouthBirthdayNotification")
      attributes[:type] = attributes[:type].sub("Notification", "Notifier")

      attributes[:params] = Noticed::Coder.load(notification.params)
      attributes[:params] = {} if attributes[:params].try(:has_key?, "noticed_error") # Skip invalid records

      # Extract related record to `belongs_to :record` association
      # This allows ActiveRecord associations instead of querying the JSON data
      # attributes[:record] = attributes[:params].delete(:user) || attributes[:params].delete(:account)

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

    puts "Finished migrating Notification data. (#{(Time.now - start).round(2)} seconds)"
  end

  desc "Seed fake notification records locally for testing purposes"
  task seed: :environment do
    if Rails.env.local?
      puts "Seeding fake notification records..."
    else
      raise "Seeding only available in test environments."
    end

    start = Time.now
    count = 0

    User.all.to_a.each_with_index do |user, i|
      next if i.even?

      FactoryBot.create(:notification, :followup_with_note_notification, recipient_id: user.id)
      FactoryBot.create(:notification, :followup_read_notification, recipient_id: user.id)
      FactoryBot.create(:notification, :followup_without_note_notification, recipient_id: user.id)

      count += 3
    end

    puts "Finished seeding #{count} records. (#{(Time.now - start).round(2)} seconds)"
  end
end
