FactoryBot.define do
  factory :case_court_mandate do
    casa_case
    mandate_text { Faker::Lorem.paragraph(sentence_count: 5, supplemental: true, random_sentences_to_add: 20) }
    implementation_status { [:not_implemented, :partially_implemented, :implemented].sample }
  end
end
