FactoryBot.define do
  factory :emancipation_option do
    emancipation_category
    sequence(:name) { |n| "Emancipation option #{n}" }
  end
end
