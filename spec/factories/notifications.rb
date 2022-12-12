FactoryBot.define do
  factory :notification do
    association :recipient, factory: :volunteer
    recipient_type { "Volunteer" }
    type { "FollowupResolvedNotification" }

    trait :followup do
      type { "FollowupNotification" }
      with_follow_up
    end

    trait(:with_follow_up) { followup }
    #following the relationship between courtdates and judges?
    #I think transient traits would be a good place to pick up
  end
end
