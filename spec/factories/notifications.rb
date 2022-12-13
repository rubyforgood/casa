FactoryBot.define do
  factory :notification do
    association :recipient, factory: :volunteer
    recipient_type { "Volunteer" }
    type { "FollowupResolvedNotification" }

    trait :followup do
      transient do
        creator { build(:user) }
      end

      type { "FollowupNotification" }
      params {
        {
          followup: create(:followup, creator: creator),
          created_by: creator
        }
      }
    end
  end
end
