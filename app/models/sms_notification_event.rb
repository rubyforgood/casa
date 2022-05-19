class SmsNotificationEvent < ApplicationRecord
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
