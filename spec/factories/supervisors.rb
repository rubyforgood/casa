FactoryBot.define do
  factory :supervisor, class: "Supervisor", parent: :user do
    display_name { Faker::Name.unique.name }
    active { true }

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

    trait :with_volunteers do
      after(:create) do |user, _|
        create_list(:supervisor_volunteer, 2, supervisor: user)
      end
    end

    trait :inactive do
      active { false }
    end

    trait :receive_reimbursement_attachment do
      receive_reimbursement_email { true }
    end
  end
end
