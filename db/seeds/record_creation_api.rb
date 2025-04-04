def seed_additional_expense(case_contact: nil, case_contact_id: nil)
  if case_contact.nil? && case_contact_id.nil?
    raise ArgumentError.new("case_contact: or case_contact_id: is required")
  elsif !case_contact.nil? && !case_contact_id.nil?
    raise ArgumentError.new("cannot use case_contact: and case_contact_id:")
  end

  other_expense_amount = rand(1..40) + rand.round(2)
  other_expenses_describe = Faker::Commerce.product_name

  if !case_contact.nil?
    AdditionalExpense.create(other_expense_amount:, other_expenses_describe:, case_contact:)
  else
    AdditionalExpense.create(other_expense_amount:, other_expenses_describe:, case_contact_id:)
  end
end

# # Seeder API
#
#  A File containing functions that satisfy:
#  - each function creates only one kind of record
#  - 2 functions per relevant model
#   - one to create a single record of the model
#    - if a record requires other records to exist they are passed in as an argument to the function
#     - accepts an active record object or a database id for each required object
#     - error checking to make sure each of the required objects is present
#   - one to create n records of the model
#    - if a record requires other records to exist they are passed in as an argument to the function
#    - the collection(s) are completely error checked so no partial record creation is possible
#  - each function returns the activerecord collection of the created record(s)

#
# addresses
# all_casa_admins
# api_credentials
# banners
# casa_case_contact_types
# casa_case_emancipation_categories
# casa_cases
# casa_cases_emancipation_options
# casa_orgs
# case_assignments
# case_contact_contact_types
# case_contacts
# case_court_orders
# case_group_memberships
# case_groups
# checklist_items
# contact_topic_answers
# contact_topics
# contact_type_groups
# contact_types
# court_dates
# delayed_jobs
# emancipation_categories
# emancipation_options
# flipper_features
# flipper_gates
# followups
# fund_requests
# healths
# hearing_types
# judges
# languages
# learning_hour_topics
# learning_hour_types
# learning_hours
# login_activities
# mileage_rates
# notes
# noticed_events
# noticed_notifications
# notifications
# other_duties
# patch_note_groups
# patch_note_types
# patch_notes
# placement_types
# placements
# preference_sets
# sent_emails
# sms_notification_events
# supervisor_volunteers
# task_records
# user_languages
# user_reminder_times
# user_sms_notification_events
# users
