FactoryBot.define do
  factory :user_case_contact_types_reminder do
    user { create(:user) }
    reminder_sent { DateTime.now }
  end
end
