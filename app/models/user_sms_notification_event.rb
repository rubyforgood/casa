class UserSmsNotificationEvent < ApplicationRecord
  belongs_to :user
  belongs_to :sms_notification_event
end

# == Schema Information
#
# Table name: user_sms_notification_events
#
#  id                        :bigint           not null, primary key
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  sms_notification_event_id :bigint           not null
#  user_id                   :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (sms_notification_event_id => sms_notification_events.id)
#  fk_rails_...  (user_id => users.id)
#
