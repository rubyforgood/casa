FactoryBot.define do
  factory :learning_hour_topic do
    casa_org { CasaOrg.first || create(:casa_org) }
    sequence(:name) { |n| "Learning Hour Type #{n}" }
    position { 1 }
  end
end
