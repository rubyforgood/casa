FactoryBot.define do
  factory :placement_type do
    sequence(:name) { |n| "Placement Type #{n}" }
    casa_org
  end
end
