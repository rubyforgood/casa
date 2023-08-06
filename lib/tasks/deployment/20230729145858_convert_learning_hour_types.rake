# After PR 5048, this is no longer needed

# namespace :after_party do
#   desc "Deployment task: converts_learning_type_enum_to_learning_hour_types_for_casa_orgs"
#   task convert_learning_hour_types: :environment do
#     puts "Running deploy task 'convert_learning_hour_types'"
#
#     learning_types = %w[book movie webinar conference other]
#     CasaOrg.all.each do |casa_org|
#       user_ids = casa_org.users.pluck(:id)
#       learning_hours = LearningHour.where(user_id: user_ids)
#
#       learning_types.each do |learning_type|
#         learning_hour_type = if learning_type == "other"
#           casa_org.learning_hour_types.find_or_create_by!(
#             name: learning_type.capitalize,
#             position: 99
#           )
#         else
#           casa_org.learning_hour_types.find_or_create_by!(name: learning_type.capitalize)
#         end
#
#         learning_hours.where(learning_type: learning_type).update_all(learning_hour_type_id: learning_hour_type.id)
#       end
#     end
#
#     # Update task as completed.  If you remove the line below, the task will
#     # run with every deploy (or every time you call after_party:run).
#     AfterParty::TaskRecord
#       .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
#   end
# end
