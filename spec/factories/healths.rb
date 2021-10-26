FactoryBot.define do
  factory :health do
    latest_deploy_time { "2021-10-25 09:37:09" }
    singleton_guard { 1 }
  end
end
