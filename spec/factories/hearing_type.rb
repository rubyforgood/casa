FactoryBot.define do
  factory :hearing_type do
    casa_org { create(:casa_org) }
    name { "Emergency Hearing" }
    active { true }
  end
end
