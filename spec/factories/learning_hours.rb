FactoryBot.define do
  factory :learning_hour, class: LearningHour, parent: :volunteer do
    name {"New Learning Hour"}
    duration_minutes { 1 }
    occurred_at { "2022-03-24 10:17:58" }
  end
end
