FactoryBot.define do
  factory :health do
    latest_deploy_time { Time.zone.now }
    singleton_guard { 0 }
  end
end
