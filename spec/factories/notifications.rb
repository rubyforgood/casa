FactoryBot.define do
  factory :notification do
    association :recipient, factory: :volunteer
    recipient_type { "Volunteer" }
    type { "FollowupResolvedNotification" }
  end
end
