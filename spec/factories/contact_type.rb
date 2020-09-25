FactoryBot.define do
  factory :contact_type do
    association :contact_type_group
    sequence(:name) { |n| "Type #{n}" }
  end
end
