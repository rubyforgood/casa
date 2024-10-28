FactoryBot.define do
  factory :learning_hour do
    transient do
      casa_org do
        @overrides[:learning_hour_type].try(:casa_org) ||
          @overrides[:user].try(:casa_org) ||
          CasaOrg.first ||
          association(:casa_org)
      end
    end

    user { association(:user, casa_org:) }
    learning_hour_type { association(:learning_hour_type, casa_org:) }

    sequence(:name) { |n| "Learning Hour #{n}" }
    duration_minutes { 25 }
    duration_hours { 1 }
    occurred_at { 2.days.ago }
  end
end
