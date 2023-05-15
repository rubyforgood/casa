FactoryBot.define do
  factory :language do
    sequence(:name) { |n| "Language #{n} - #{Faker::Nation.language}" }
    casa_org { CasaOrg.first || create(:casa_org) }
  end
end
