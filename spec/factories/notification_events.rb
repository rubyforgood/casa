FactoryBot.define do
  factory :followup_notification do
    type { "FollowupNotification" }

    trait :with_note do
      params do
        {
          followup: attributes_for(:followup, :with_note),
          created_by: attributes_for(:user)
        }
      end
    end

    trait :without_note do
      params do
        {
          followup: attributes_for(:followup, :without_note, case_contact_id: create(:case_contact).id)
        }
      end
    end

    trait :read do
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
    params do
      {
        casa_case: create(:casa_case)
      }
    end
  end

  factory :reimbursement_complete_notification do
    type { "ReimbursementCompleteNotification" }
    params do
      {
        case_contact: create(:case_contact)
      }
    end
  end
end
