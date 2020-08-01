FactoryBot.define do
  factory :supervisor, class: "Supervisor", parent: :user do
    role { :supervisor }

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
