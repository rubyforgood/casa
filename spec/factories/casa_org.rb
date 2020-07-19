FactoryBot.define do
  factory :casa_org do
    sequence(:name) { |n| "CASA Org #{n}" }
  end
end
