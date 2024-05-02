FactoryBot.define do
  factory :login_activity do
    user { User.first || create(:user) }
    sequence(:email) { |n| "email#{n}@example.com" }
    current_sign_in_at { 2.days.ago }
    current_sign_in_ip { "127.0.0.1" }
    user_type { "Volunteer" }
  end
end
