# Temporarily define the Notification model to access the old table
class Notification < ActiveRecord::Base
  self.inheritance_column = nil
end

namespace :notifications do
  desc "Migrates existing notifications to new tables for noticed gem v2.x"
  task migrate: :environment do
    puts "Migrating notification data..."
    start = Time.now

    # Migrate each record to the new tables
    Notification.find_each do |notification|
      attributes = notification.attributes.slice("type", "created_at", "updated_at").with_indifferent_access

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
    Rails.env.local? ? puts("Seeding fake notification records...") : raise("Seeding only available in test environments.")

    start = Time.now
    count = 0

    User.all.to_a.each_with_index do |user, i|
      next if i.even?

      FactoryBot.create(:followup_notification, :with_note)
      FactoryBot.create(:followup_notification, :without_note)
      FactoryBot.create(:followup_notification, :read)

      count += 3
    end

    puts "Finished seeding #{count} records. (#{(Time.now - start).round(2)} seconds)"
  end
end
