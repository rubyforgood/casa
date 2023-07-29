FactoryBot.define do
  factory :learning_hour_type do
    casa_org { CasaOrg.first || create(:casa_org) }
    name { Faker::Book.genre }
    active { false }
    position { 1 }
  end
end
