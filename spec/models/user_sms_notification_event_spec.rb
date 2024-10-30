require "rails_helper"

RSpec.describe UserSmsNotificationEvent, type: :model do
  specify do
    expect(subject).to belong_to(:user)
    expect(subject).to belong_to(:sms_notification_event)
  end
end
