FactoryBot.define do
  factory :casa_case do
    sequence(:case_number) { |n| n }
    transition_aged_youth { false }

    before(:create) { |casa_case, _| create(:case_assignment, casa_case: casa_case) }
  end
end
