FactoryBot.define do
  factory :followup_notifier do
    type { "FollowupNotifier" }

    trait :with_note do
      params do
        {
          followup: create(:followup, :with_note),
          created_by: create(:user)
        }
      end
    end

    trait :without_note do
      params do
        {
          followup: create(:followup, :without_note, case_contact_id: create(:case_contact).id)
        }
      end
    end

    trait :read do
      params do
        {
          followup: create(:followup, :without_note, case_contact_id: create(:case_contact).id)
        }
      end
    end
  end

  factory :emancipation_checklist_reminder_notifier do
    type { "EmancipationChecklistReminderNotifier" }
    params do
      {
        casa_case: create(:casa_case)
      }
    end
  end

  factory :youth_birthday_notifier do
    type { "YouthBirthdayNotifier" }
    params do
      {
        casa_case: create(:casa_case)
      }
    end
  end

  factory :reimbursement_complete_notifier do
    type { "ReimbursementCompleteNotifier" }
    params do
      {
        case_contact: create(:case_contact)
      }
    end
  end
end
