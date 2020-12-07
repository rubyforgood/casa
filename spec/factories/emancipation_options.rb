FactoryBot.define do
  factory :emancipation_option do
    emancipation_category { build(:emancipation_category) }
    name { "MyString" }
  end
end
