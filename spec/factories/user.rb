FactoryBot.define do
  factory :user do
    casa_org { create(:casa_org) }
    sequence(:email) { |n| "email#{n}@example.com" }
    password { "123456" }
    password_confirmation { "123456" }

    trait :volunteer do
      role { :volunteer }
    end

    trait :supervisor do
      role { :supervisor }
    end

    trait :with_casa_case do
      casa_cases { create_list(:casa_case, 2) }
    end
  end
end
