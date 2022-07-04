require "rails_helper"

RSpec.describe UserReminderTime, type: :model do
  it { is_expected.to belong_to(:user) }
end
