FactoryBot.define do
  factory :supervisor_volunteer do
    association :supervisor, factory: :user
    association :volunteer, factory: :user
  end
end
