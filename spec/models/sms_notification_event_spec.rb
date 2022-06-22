require "rails_helper"

RSpec.describe SmsNotificationEvent, type: :model do
  it { is_expected.to have_many(:user_sms_notification_events) }
  it { is_expected.to have_many(:users).through(:user_sms_notification_events) }
end
