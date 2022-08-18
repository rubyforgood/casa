FactoryBot.define do
  factory :address do
    content { "" }
    association :user
  end
end
