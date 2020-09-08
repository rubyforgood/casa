FactoryBot.define do
  factory :supervisor_volunteer do
    association :supervisor, factory: :supervisor
    association :volunteer, factory: :volunteer
  end
end
