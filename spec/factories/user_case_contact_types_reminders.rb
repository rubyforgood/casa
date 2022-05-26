FactoryBot.define do
  factory :user_case_contact_types_reminder do
    user { create(:user) }
    reminder_sent { "2022-05-25 19:18:48" }
  end
end
