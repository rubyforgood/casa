FactoryBot.define do
  factory :user do
    casa_org { create(:casa_org) }
    sequence(:email) { |n| "email#{n}@example.com" }
    password { '123456' }
    password_confirmation { '123456' }

    trait :volunteer do
      role { :volunteer }
    end

    trait :supervisor do
      role { :supervisor }
    end

    trait :casa_admin do
      role { :casa_admin }
    end

    trait :with_casa_cases do
      after(:create) do |user, _|
        create_list(:case_assignment, 2, volunteer: user)
      end
    end
  end
end
