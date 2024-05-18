FactoryBot.define do
  factory :followup_notifier do
    type { "FollowupNotification" }
    record_type { "FollowupNotification::Notification" }
    params do
      {
        created_by: attributes_for(:user)
      }
    end

    trait :with_note do
      association :record, factory: :notification
      params do
        {
          followup: attributes_for(:followup, :with_note, case_contact_id: create(:case_contact).id)
        }
      end
    end

    trait :without_note do
      association :record, factory: :notification
      params do
        {
          followup: attributes_for(:followup, :without_note, case_contact_id: create(:case_contact).id)
        }
      end
    end

    trait :read do
      association :record, factory: [:notification, :followup_read]
      params do
        {
          followup: attributes_for(:followup, :without_note, case_contact_id: create(:case_contact).id)
        }
      end
    end
  end

  factory :emancipation_checklist_reminder_notifier do
    type { "EmancipationChecklistReminderNotification" }
    record_type { "EmancipationChecklistReminderNotification::Notification" }
    association :record, factory: :notification
    params do
      {
        casa_case: create(:casa_case)
      }
    end
  end

  factory :youth_birthday_notifier do
    type { "YouthBirthdayNotification" }
    record_type { "YouthBirthdayNotification::Notification" }
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
    association :event, factory: :followup_notifier
    association :recipient, factory: :user
    recipient_type { "User" }

    trait :followup_read do
      read_at { DateTime.current }
      seen_at { DateTime.current }
    end

    trait :emancipation_checklist_reminder do
      association :event, factory: :emancipation_checklist_reminder_notifier
    end

    trait :youth_birthday do
      association :event, factory: :youth_birthday_notifier
    end
  end
end