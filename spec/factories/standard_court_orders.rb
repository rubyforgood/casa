FactoryBot.define do
  factory :standard_court_order do
    value { "Some standard court order" }
    casa_org { CasaOrg.first || create(:casa_org) }
  end
end
