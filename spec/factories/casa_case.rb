FactoryBot.define do
  factory :casa_case do
    association :volunteer, factory: :user

    sequence(:case_number) { |n| n  }
    teen_program_eligible { false }
  end
end
