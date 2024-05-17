FactoryBot.define do
  factory :followup_notifier, class: FollowupNotifier do
    type { "FollowupNotifier" }
    record_type { "FollowupNotifier::Notification" }

    trait :with_note do
      association :record, factory: [:notification, :followup_with_note]
      params do
        {
          followup: attributes_for(:followup, :with_note, case_contact_id: create(:case_contact).id),
          created_by: attributes_for(:user)
        }
      end
    end

    trait :without_note do
      association :record, factory: [:notification, :followup_without_note]
      params do
        {
          followup: attributes_for(:followup, :without_note, case_contact_id: create(:case_contact).id),
          created_by: attributes_for(:user)
        }
      end
    end

    trait :read do
      association :record, factory: [:notification, :followup_read]
      params do
        {
          followup: attributes_for(:followup, :without_note, case_contact_id: create(:case_contact).id),
          created_by: attributes_for(:user)
        }
      end
    end
  end

  factory :emancipation_checklist_reminder_notifier, class: EmancipationChecklistReminderNotifier do
    type { "EmancipationChecklistReminderNotifier" }
    record_type { "EmancipationChecklistReminderNotifier::Notification" }
    trait :default do
      association :record, factory: [:notification, :emancipation_checklist_reminder]
      params do
        {
          casa_case: create(:casa_case)
        }
      end
    end
  end

  factory :youth_birthday_notifier, class: YouthBirthdayNotifier do
    type { "YouthBirthdayNotifier" }
    record_type { "YouthBirthdayNotifier::Notification" }
    trait :default do
      association :record, factory: [:notification, :youth_birthday]
      params do
        {
          casa_case: create(:casa_case)
        }
      end
    end
  end

end

FactoryBot.define do
  factory :notification, class: Noticed::Notification do
    association :recipient, factory: :user
    recipient_type { "User" }

    trait :followup_with_note do
      association :event, factory: :followup_notifier
    end

    trait :followup_without_note do
      association :event, factory: :followup_notifier
    end

    trait :followup_read do
      association :event, factory: :followup_notifier
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