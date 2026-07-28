# Prosopite N+1 Query Issues

Issues detected by Prosopite during test suite run. Fix by adding eager loading (`includes`, `preload`) or restructuring queries.

## High Priority (20+ occurrences)

### app/decorators/casa_case_decorator.rb:34
- **Method:** `map` in decorator
- **Likely fix:** Add `includes` for associated records being accessed in iteration

### app/models/user.rb:84
- **Method:** `create_preference_set`
- **Query:** `SELECT "preference_sets".* FROM "preference_sets" WHERE "preference_sets"."user_id" = $1`
- **Likely fix:** Check if preference_set already loaded before querying

### app/models/concerns/api.rb:11
- **Method:** `initialize_api_credentials`
- **Query:** `SELECT "api_credentials".* FROM "api_credentials" WHERE "api_credentials"."user_id" = $1`
- **Likely fix:** Check if api_credentials already loaded before querying

### app/lib/importers/file_importer.rb:50
- **Method:** `create_user_record`
- **Queries:** Multiple user lookups during import
- **Likely fix:** Batch lookups or use `Prosopite.pause` for intentional import operations

## Medium Priority (10-19 occurrences)

### app/validators/user_validator.rb:56
- **Method:** `validate_uniqueness`
- **Query:** `SELECT "users".* FROM "users" WHERE "users"."type" = $1 AND "users"."email" = $2`
- **Likely fix:** Consider if validation is necessary during bulk operations

### app/lib/importers/supervisor_importer.rb:47
- **Method:** `block in assign_volunteers`
- **Query:** `SELECT "users".* FROM "users" INNER JOIN "supervisor_volunteers"...`
- **Likely fix:** Preload volunteers before assignment loop

### app/lib/importers/supervisor_importer.rb:51
- **Method:** `block in assign_volunteers`
- **Query:** `SELECT "users".* FROM "users" WHERE "users"."id" = $1`
- **Likely fix:** Batch load users by ID before iteration

### app/controllers/case_contacts/form_controller.rb:156
- **Method:** `block in create_additional_case_contacts`
- **Likely fix:** Eager load case contact associations

## Lower Priority (5-9 occurrences)

### app/models/court_date.rb:32
- **Method:** `associated_reports`
- **Likely fix:** Add `includes` for court report associations

### app/lib/importers/supervisor_importer.rb:23
- **Method:** `block in import_supervisors`
- **Query:** `SELECT "users".* FROM "users" WHERE "users"."type" = $1 AND "users"."email" = $2`
- **Likely fix:** Batch check existing supervisors before import loop

## Lower Priority (2-4 occurrences)

### app/lib/importers/file_importer.rb:57
- **Method:** `email_addresses_to_users`
- **Likely fix:** Batch load users by email

### app/lib/importers/case_importer.rb:41
- **Method:** `create_casa_case`
- **Likely fix:** Preload or batch casa_case lookups

### app/decorators/contact_type_decorator.rb:14
- **Method:** `last_time_used_with_cases`
- **Likely fix:** Eager load case associations

### app/datatables/reimbursement_datatable.rb:25
- **Method:** `block in data`
- **Query:** `SELECT "addresses".* FROM "addresses" WHERE "addresses"."user_id" = $1`
- **Likely fix:** Add `includes(:address)` to reimbursement query

### app/services/volunteer_birthday_reminder_service.rb:7
- **Method:** `block in send_reminders`
- **Likely fix:** Eager load volunteer associations

### app/models/contact_topic.rb:27
- **Method:** `block in generate_for_org!`
- **Likely fix:** Batch operations or use `Prosopite.pause` for setup

### app/models/casa_org.rb:82
- **Method:** `user_count`
- **Likely fix:** Use counter cache or single count query

### app/models/casa_org.rb:62
- **Method:** `case_contacts_count`
- **Likely fix:** Use counter cache or single count query

### app/lib/importers/volunteer_importer.rb:23
- **Method:** `block in import_volunteers`
- **Likely fix:** Batch check existing volunteers before import loop

### app/lib/importers/case_importer.rb:20
- **Method:** `block in import_cases`
- **Likely fix:** Batch check existing cases before import loop

### app/controllers/case_contacts/form_controller.rb:26
- **Method:** `block (2 levels) in update`
- **Likely fix:** Eager load contact associations

## Single Occurrence

### app/services/missing_data_export_csv_service.rb:40
- **Method:** `full_data`

### app/policies/contact_topic_answer_policy.rb:18
- **Method:** `create?`

### app/models/casa_case.rb:152
- **Method:** `next_court_date`

### app/models/all_casa_admins/casa_org_metrics.rb:16
- **Method:** `map`

### config/initializers/sent_email_event.rb:7
- **Method:** `block in <top (required)>`
- **Query:** `SELECT "casa_orgs".* FROM "casa_orgs" WHERE "casa_orgs"."id" = $1`
- **Note:** Initializer callback - consider caching org lookup

## Notes

- **Importers:** Many N+1s occur in import code. Consider wrapping entire import operations in `Prosopite.pause { }` if the N+1 pattern is intentional for per-record processing, or batch-load records before iteration.

- **Decorators:** Add `includes` at the controller/query level before passing to decorators.

- **Callbacks:** User model callbacks (`create_preference_set`, `initialize_api_credentials`) fire on each create. Consider if these can be optimized or if the N+1 is acceptable for single-record operations.

## How to Fix

```ruby
# Before (N+1)
users.each { |u| u.orders.count }

# After (eager loading)
users.includes(:orders).each { |u| u.orders.count }

# For intentional batch operations
Prosopite.pause do
  records.each { |r| process_individually(r) }
end
```
