FactoryBot.define do
  factory :case_court_mandate do
    association :casa_case
    mandate_text { Faker::Lorem.paragraph(sentence_count: 5, supplemental: true, random_sentences_to_add: 20) }
  end
end
