FactoryBot.define do
  factory :followup_notification do
    type { "FollowupNotification" }

    trait :with_note do
      association :record, factory: [:notification, :with_note]
      params do
        {
          followup: attributes_for(:followup, :with_note, case_contact_id: create(:case_contact).id),
          created_by: attributes_for(:user)
        }
      end
    end

    trait :without_note do
      association :record, factory: [:notification, :without_note]
      params do
        {
          followup: attributes_for(:followup, :without_note, case_contact_id: create(:case_contact).id)
        }
      end
    end

    trait :read do
      association :record, factory: [:notification, :read]
      params do
        {
          followup: attributes_for(:followup, :without_note, case_contact_id: create(:case_contact).id)
        }
      end
    end
  end

  factory :emancipation_checklist_reminder_notification do
    type { "EmancipationChecklistReminderNotification" }
    params do
      {
        casa_case: create(:casa_case)
      }
    end
  end

  factory :youth_birthday_notification do
    type { "YouthBirthdayNotification" }
    record_type { "YouthBirthdayNotification::Notification" }
    association :record, factory: :notification
    params do
      {
        casa_case: create(:casa_case)
      }
    end
  end

  factory :reimbursement_complete_notification do
    type { "ReimbursementCompleteNotification" }
    record_type { "ReimbursementCompleteNotification::Notification" }
    association :record, factory: :notification
    params do
      {
        casa_case: create(:casa_case)
      }
    end
  end
end

FactoryBot.define do
  factory :notification, class: Noticed::Notification do
    association :recipient, factory: :volunteer
    recipient_type { "User" }

    trait :with_note do
      type { "FollowupNotification::Notification" }
    end

    trait :without_note do
      type { "FollowupNotification::Notification" }
    end

    trait :read do
      type { "FollowupNotification::Notification" }
      read_at { DateTime.current }
      seen_at { DateTime.current }
    end

    trait :emancipation_checklist_reminder do
      type { "EmancipationChecklistReminderNotification::Notification" }
      association :event, factory: :emancipation_checklist_reminder_notification
    end

    trait :youth_birthday do
      association :event, factory: :youth_birthday_notification
    end
  end
end