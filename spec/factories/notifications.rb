FactoryBot.define do
  factory :notification, class: Noticed::Notification do
    association :recipient, factory: :volunteer
    recipient_type { "User" }
    type { "FollowupNotification::Notification" }

    trait :followup_with_note do
      event { association(:followup_notification, :with_note) }
    end

    trait :followup_without_note do
      event { association(:followup_notification, :without_note) }
    end

    trait :followup_read do
      event { association(:followup_notification, :read) }
      read_at { DateTime.current }
      seen_at { DateTime.current }
    end

    trait :emancipation_checklist_reminder do
      event { association(:emancipation_checklist_reminder_notification) }
      type { "EmancipationChecklistReminderNotification::Notification" }
    end

    trait :youth_birthday do
      event { association(:youth_birthday_notification) }
      type { "YouthBirthdayNotification::Notification" }
    end

    trait :reimbursement_complete do
      event { association(:reimbursement_complete_notification) }
      type { "ReimbursementCompleteNotification::Notification" }
    end
  end
end