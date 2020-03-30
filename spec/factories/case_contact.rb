FactoryBot.define do
  factory :case_contact do
    association :creator, factory: :user
    association :casa_case

    contact_type { "therapist" }
    duration_minutes { 60 }
    occurred_at { Time.zone.now }
  end
end
