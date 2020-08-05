FactoryBot.define do
  factory :volunteer, class: "Volunteer", parent: :user do
    trait :inactive do
      active { false }
    end

    trait :with_casa_cases do
      after(:create) do |user, _|
        create_list(:case_assignment, 2, volunteer: user)
      end
    end
  end
end
