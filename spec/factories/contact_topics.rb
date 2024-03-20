FactoryBot.define do
  factory :contact_topic do
    casa_org
    active { true }
    question { Faker::Lorem.sentence }
    details { Faker::Lorem.paragraph_by_chars(number: 300) }
  end
end
