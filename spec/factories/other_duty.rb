FactoryBot.define do
  factory :other_duty do
    creator { association :user }
    creator_type { "" }
    occurred_at { Date.current }
    duration_minutes { rand(99) }
    notes { Faker::Lorem.paragraph(sentence_count: 5, supplemental: true, random_sentences_to_add: 20) }
  end
end
