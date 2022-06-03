FactoryBot.define do
  factory :learning_hour do
    user
    name { "New Learning Hour" }
    duration_hours { 1 }
    duration_minutes { 2 }
    occurred_at { "2022-03-24 10:17:58" }
  end
end
