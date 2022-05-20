class SmsNotificationEvent < ApplicationRecord
  has_many :user_sms_notification_events
  has_many :users, through: :user_sms_notification_events
end

# == Schema Information
#
# Table name: sms_notification_events
#
#  id         :bigint           not null, primary key
#  name       :string
#  user_type  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
