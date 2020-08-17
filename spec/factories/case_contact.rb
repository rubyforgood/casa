FactoryBot.define do
  factory :case_contact do
    association :creator, factory: :user
    association :casa_case

    contact_types { ["therapist"] }
    duration_minutes { 60 }
    occurred_at { Time.zone.now }
    contact_made { false }
    contact_medium { "text/email"}
    miles_driven { nil }
    want_driving_reimbursement { false }

    trait :miles_driven_no_reimbursement do
      miles_driven { 20 }
    end

    trait :wants_reimbursement do
      miles_driven { 20 }
      want_driving_reimbursement { true }
    end
  end
end
