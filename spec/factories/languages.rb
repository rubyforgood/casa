FactoryBot.define do
  factory :language do
    name { Faker::Nation.language }
    casa_org { CasaOrg.first || create(:casa_org) }
  end
end
