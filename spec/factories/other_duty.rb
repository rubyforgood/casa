FactoryBot.define do
  factory :other_duty do
    creator { association :user }
    creator_type { creator.role }
    occurred_at { Date.current }
    duration_minutes { rand(99) }
    notes { Faker::Books::Dune.quote }
  end
end
