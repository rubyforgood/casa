FactoryBot.define do
  factory :address do
    content { Faker::Address.full_address }
  end
end
