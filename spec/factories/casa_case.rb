FactoryBot.define do
  factory :casa_case do
    sequence(:case_number) { |n| n  }
    teen_program_eligible { false }

    before(:create) do |casa_case, _|
      create(:case_assignment, casa_case: casa_case)
    end
  end
end
