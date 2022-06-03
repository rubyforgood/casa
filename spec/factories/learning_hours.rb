FactoryBot.define do
  factory :learning_hour do
    user { User.first || create(:user) }
    name { Faker::Book.title }
    duration_minutes { 25 }
    duration_hours { 1 }
    occurred_at { 2.days.ago  }
  end
end
