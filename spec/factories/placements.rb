FactoryBot.define do
  factory :placement do
    casa_case
    placement_type
    placement_started_at { DateTime.now }
    creator { association :user }
  end
end
