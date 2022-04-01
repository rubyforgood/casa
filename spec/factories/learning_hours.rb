FactoryBot.define do
  factory :learning_hour do
    user = User.first
    user_id { user.id }
    name { "New Learning Hour" }
    duration_minutes { 1 }
    occurred_at { "2022-03-24 10:17:58" }
  end
end
