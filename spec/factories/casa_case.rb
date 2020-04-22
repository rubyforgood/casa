FactoryBot.define do
  factory :casa_case do
    sequence(:case_number) { |n| n }
    teen_program_eligible { false }

    before(:create) { |casa_case, _| create(:case_assignment, casa_case: casa_case) }
  end
end
