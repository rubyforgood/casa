FactoryBot.define do
  factory :user do
    casa_org { CasaOrg.first || create(:casa_org) }
    sequence(:email) { |n| "email#{n}@example.com" }
    sequence(:display_name) { |n| "User #{n}" }
    password { "12345678" }
    password_confirmation { "12345678" }
    date_of_birth { nil }
    phone_number { "" }
    confirmed_at { Time.zone.now }
    token { "verysecuretoken" }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :receive_reimbursement_attachment do
      receive_reimbursement_email { true }
    end
  end
end
