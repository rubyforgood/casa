FactoryBot.define do
  factory :language do
    sequence(:name) { |n| "Language #{n} - #{Faker::Nation.language}" }
    casa_org { association :casa_org }
  end
end
