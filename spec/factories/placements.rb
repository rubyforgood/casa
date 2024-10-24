FactoryBot.define do
  factory :placement do
    creator factory: :user
    casa_case
    placement_type
    placement_started_at { DateTime.now }
  end
end
