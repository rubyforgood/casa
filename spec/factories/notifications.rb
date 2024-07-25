FactoryBot.define do
  factory :notification, class: Noticed::Notification do
    association :recipient, factory: :volunteer
    association :event, factory: :followup_notifier
    recipient_type { "User" }
    type { "FollowupNotifier::Notification" }

    transient do
      created_by { nil }
      casa_case { nil }
    end

    before(:create) do |notification, eval|
      notification.params[:created_by] = eval.created_by if eval.created_by.present?
      notification.params[:casa_case] = eval.casa_case if eval.casa_case.present?
    end

    trait :followup_with_note do
      association :event, factory: [:followup_notifier, :with_note]
    end

    trait :followup_without_note do
      association :event, factory: [:followup_notifier, :without_note]
    end

    trait :followup_read do
      association :event, factory: [:followup_notifier, :read]
      read_at { DateTime.current }
      seen_at { DateTime.current }
    end

    trait :emancipation_checklist_reminder do
      association :event, factory: :emancipation_checklist_reminder_notifier
      type { "EmancipationChecklistReminderNotifier::Notification" }
    end

    trait :youth_birthday do
      association :event, factory: :youth_birthday_notifier
      type { "YouthBirthdayNotifier::Notification" }
    end

    trait :reimbursement_complete do
      association :event, factory: :reimbursement_complete_notifier
      type { "ReimbursementCompleteNotifier::Notification" }
    end
  end
end
