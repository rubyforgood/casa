FactoryBot.define do
  factory :notification do
    association :recipient, factory: :volunteer
    recipient_type { "User" }
    type { "Notification" }
    
    trait :followup_with_note do
      transient do
        creator { build(:user) }
      end
      type { "FollowupNotification" }
      params {
        {
          followup: create(:followup, :with_note, creator: creator),
          created_by: creator
        }
      }
      initialize_with { new(params: params) }
    end

    trait :followup_read do
      transient do
        creator { build(:user) }
      end
      type { "FollowupNotification" }
      read_at { DateTime.current }
      params {
        {
          followup: create(:followup, :with_note, creator: creator),
          created_by: creator
        }
      }
      initialize_with { new(params: params) }
    end

    trait :followup_without_note do
      transient do
        creator { build(:user) }
      end
      type { "FollowupNotification" }
      params {
        {
          followup: create(:followup, :without_note, creator: creator),
          created_by: creator
        }
      }
      initialize_with { new(params: params) }
    end

    trait :emancipation_checklist_reminder do
      type { "EmancipationChecklistReminderNotification" }
      params {
        {
          casa_case: create(:casa_case)
        }
      }
      initialize_with { new(params: params) }
    end

    trait :youth_birthday do
      type { "YouthBirthdayNotification" }
      params {
        {
          casa_case: create(:casa_case)
        }
      }
      initialize_with { new(params: params) }
    end
  end
end
