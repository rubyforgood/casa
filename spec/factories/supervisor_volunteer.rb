FactoryBot.define do
  factory :supervisor_volunteer do
    association :supervisor, factory: :supervisor
    association :volunteer, factory: :volunteer

    trait :inactive do
      is_active { false }
    end
  end
end
