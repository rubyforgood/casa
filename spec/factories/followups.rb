FactoryBot.define do
  factory :followup do
    association :creator, factory: :user
    status { :requested }
    association :followupable, factory: :case_contact  # Default association to case_contact

    trait :with_note do
      note { Faker::Lorem.sentence }
    end

    trait :without_note do
      note { "" }
    end
  end
end
