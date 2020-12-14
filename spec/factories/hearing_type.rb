FactoryBot.define do
  factory :hearing_type do
    casa_org { CasaOrg.first || create(:casa_org) }
    sequence(:name) { |n| "Emergency Hearing #{n}" }
    active { true }
  end
end
