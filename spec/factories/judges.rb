FactoryBot.define do
  factory :judge do
    casa_org { create(:casa_org) }
    name { Faker::Name.name }
    active { true }
  end
end
