FactoryBot.define do
  factory :address do
    content { Faker::Address.full_address }
    association :user
  end
end
