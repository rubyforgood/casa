FactoryBot.define do
  factory :user do
    casa_org { create(:casa_org) }
    sequence(:email) { |n| "email#{n}@example.com" }
    password { "123456" }
    password_confirmation { "123456" }
    case_assignments { [] }

    trait :volunteer do
      role { :volunteer }
    end

    trait :supervisor do
      role { :supervisor }
    end

    trait :casa_admin do
      role { :casa_admin }
    end

    trait :inactive do
      role { :inactive }
    end

    trait :with_casa_cases do
      after(:create) do |user, _|
        create_list(:case_assignment, 2, volunteer: user)
      end
    end

    trait :with_case_contact do
      after(:create) do |user, _|
        create(:case_assignment, volunteer: user)
        create(:case_contact, creator: user, casa_case: user.casa_cases.first, contact_made: true)
      end
    end

    trait :with_case_contact_wants_driving_reimbursement do
      after(:create) do |user, _|
        create(:case_assignment, volunteer: user)
        create(:case_contact, :wants_reimbursement, creator: user, casa_case: user.casa_cases.first, contact_made: true)
      end
    end
  end
end
