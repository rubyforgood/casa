FactoryBot.define do
  factory :learning_hour_type do
    casa_org { CasaOrg.first || create(:casa_org) }
    sequence(:name) { |n| "Learning Hour Type #{n}" }
    active { true }
    position { 1 }
  end
end
