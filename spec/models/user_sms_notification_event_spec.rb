require "rails_helper"

RSpec.describe UserSmsNotificationEvent, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:sms_notification_event) }
end
