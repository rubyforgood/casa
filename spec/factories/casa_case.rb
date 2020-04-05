FactoryBot.define do
  factory :casa_case do
    sequence(:case_number) { |n| n  }
    teen_program_eligible { false }

    after(:create) do |casa_case, _|
      create(:user, :volunteer, casa_cases: [casa_case])
    end
  end
end
