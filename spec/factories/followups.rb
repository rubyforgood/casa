FactoryBot.define do
  factory :followup do
    association :creator, factory: :user

    status { :requested }
    case_contact

    trait :with_note do
      note { Faker::Lorem.paragraph }
    end

    trait :without_note do
      note { '' }
    end
  end
end
