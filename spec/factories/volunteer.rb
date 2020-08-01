FactoryBot.define do
  factory :volunteer, class: "Volunteer", parent: :user do
    role { :volunteer }

    trait :inactive do
      active { false }
      role { :inactive }
    end

    trait :with_casa_cases do
      after(:create) do |user, _|
        create_list(:case_assignment, 2, volunteer: user)
      end
    end
  end
end
