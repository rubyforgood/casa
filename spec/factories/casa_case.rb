FactoryBot.define do
  factory :casa_case do
    sequence(:case_number) { |n| n }
    transition_aged_youth { false }
    casa_org
  end
end
