FactoryBot.define do
  factory :case_assignment do
    is_active { true }

    association :casa_case
    association :volunteer, factory: :volunteer
  end
end
