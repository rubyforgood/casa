FactoryBot.define do
  factory :feature_flag do
    sequence(:name) { |n| "feature_name #{n}" }
    enabled { true }
  end
end
