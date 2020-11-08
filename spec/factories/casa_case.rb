FactoryBot.define do
  factory :casa_case do
    sequence(:case_number) { |n| n }
    transition_aged_youth { false }
    birth_month_year_youth { 16.years.ago }
    casa_org
    hearing_type
    judge

    trait :with_case_assignments do
      case_assignments { build_list(:case_assignment, 2) }
    end

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
