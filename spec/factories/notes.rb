FactoryBot.define do
  factory :note do
    association :notable, factory: :user
    association :creator, factory: :user
  end
end
