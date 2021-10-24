FactoryBot.define do
  factory :mileage_rate do
    amount { "9.99" }
    effective_date { "2021-10-23" }
    is_active { true }
    user { create(:casa_admin) }
  end
end
