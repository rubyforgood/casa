FactoryBot.define do
  factory :address do
    content { Faker::Address.full_address }
    user
  end
end
