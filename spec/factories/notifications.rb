# FactoryBot.define do
#   factory :notification do
#     recipient_type { "User" }
#     type { "Notification" }
#
#     trait :followup_with_note do
#       type { "FollowupNotification" }
#       params {
#         {
#           followup: create(:followup, :with_note, creator: creator),
#           created_by: creator
#         }
#       }
#       initialize_with { new(params: params) }
#     end
#
#     trait :followup_read do
#       transient do
#         creator { build(:user) }
#       end
#       type { "FollowupNotification" }
#       read_at { DateTime.current }
#       params {
#         {
#           followup: create(:followup, :with_note, creator: creator),
#           created_by: creator
#         }
#       }
#       initialize_with { new(params: params) }
#     end
#
#     trait :followup_without_note do
#       transient do
#         creator { build(:user) }
#       end
#       type { "FollowupNotification" }
#       params {
#         {
#           followup: create(:followup, :without_note, creator: creator),
#           created_by: creator
#         }
#       }
#       initialize_with { new(params: params) }
#     end
#
#     trait :emancipation_checklist_reminder do
#       type { "EmancipationChecklistReminderNotification" }
#       params {
#         {
#           casa_case: create(:casa_case)
#         }
#       }
#       initialize_with { new(params: params) }
#     end
#
#     trait :youth_birthday do
#       type { "YouthBirthdayNotification" }
#       params {
#         {
#           casa_case: create(:casa_case)
#         }
#       }
#       initialize_with { new(params: params) }
#     end
#
#     trait :reimbursement_complete do
#       type { "ReimbursementCompleteNotification" }
#       params {
#         {
#           case_contact: create(:case_contact)
#         }
#       }
#       initialize_with { new(params: params) }
#     end
#     trait :followup_with_note_notification do
#       type { "FollowupNotification" }
#       params do
#         {
#           followup: { id: 1, note: "This is a sample followup note" },
#           created_by: { id: 1, name: "John Doe" }
#         }
#       end
#     end
#
#     trait :followup_read_notification do
#       type { "FollowupNotification" }
#       read_at { DateTime.current }
#       params do
#         {
#           followup: { id: 1, note: "This is a sample followup note" },
#           created_by: { id: 1, name: "John Doe" }
#         }
#       end
#     end
#
#     trait :followup_without_note_notification do
#       type { "FollowupNotification" }
#       params do
#         {
#           followup: { id: 1 },
#           created_by: { id: 1, name: "John Doe" }
#         }
#       end
#     end
#   end
# end
