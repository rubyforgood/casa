FactoryBot.define do
  factory :contact_topic_answer do
    case_contact
    contact_topic
    selected { false }
    value { Faker::Lorem.paragraph_by_chars(number: 300) }
  end
end
