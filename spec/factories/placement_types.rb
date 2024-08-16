FactoryBot.define do
  factory :placement_type do
    casa_org
    sequence(:name) { |n| "Placement Type #{n}" }
  end
end
