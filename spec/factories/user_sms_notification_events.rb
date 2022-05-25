FactoryBot.define do
  factory :user_sms_notification_event do
    user { create(:user) }
    sms_notification_event { create(:sms_notification_event) }
  end
end
