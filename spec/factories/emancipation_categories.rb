FactoryBot.define do
  factory :emancipation_category do
    sequence(:name) { |n| "Emancipation category #{n}" }
    mutually_exclusive { false }
  end
end
