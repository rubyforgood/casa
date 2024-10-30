require "rails_helper"

RSpec.describe SmsNotificationEvent, type: :model do
  specify do
    expect(subject).to have_many(:user_sms_notification_events)
    expect(subject).to have_many(:users).through(:user_sms_notification_events)
  end
end
