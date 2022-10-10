FactoryBot.define do
  factory :case_court_order do
    casa_case
    text { Faker::Lorem.paragraph(sentence_count: 5, supplemental: true, random_sentences_to_add: 20) }
    implementation_status { [:unimplemented, :partially_implemented, :implemented].sample }
  end
end
