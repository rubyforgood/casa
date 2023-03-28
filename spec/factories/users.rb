FactoryBot.define do
  factory :user do
    casa_org { CasaOrg.first || create(:casa_org) }
    sequence(:email) { |n| "email#{n}@example.com" }
    email_confirmation { |u| u.email }
    sequence(:display_name) { |n| "User #{n}" }
    password { "12345678" }
    password_confirmation { "12345678" }
    case_assignments { [] }
    phone_number { "" }
    confirmed_at { Time.now }

    trait :inactive do
      volunteer
      active { false }
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
