FactoryBot.define do
  factory :placement do
    placement_type
    placement_started_at { DateTime.now }
    creator { association :user }
  end
end
