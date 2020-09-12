FactoryBot.define do
  factory :casa_case do
    sequence(:case_number) { |n| n }
    transition_aged_youth { false }
    casa_org

    trait :with_case_assignments do
      case_assignments { build_list(:case_assignment, 2) }
    end
  end
end
