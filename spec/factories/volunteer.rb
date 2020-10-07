FactoryBot.define do
  factory :volunteer, class: "Volunteer", parent: :user do
    trait :inactive do
      active { false }
    end

    trait :with_casa_cases do
      after(:create) do |user, _|
        create(:case_assignment, casa_case: create(:casa_case, casa_org: user.casa_org), volunteer: user)
        create(:case_assignment, casa_case: create(:casa_case, casa_org: user.casa_org), volunteer: user)
      end
    end

    trait :with_assigned_supervisor do
      after(:create) do |user, _|
        create(:supervisor_volunteer, volunteer: user)
      end
    end

    trait :with_inactive_supervisor do
      after(:create) do |user, _|
        create(:supervisor_volunteer, :inactive, volunteer: user)
      end
    end
  end
end
