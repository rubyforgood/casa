# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_07_29_145419) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "additional_expenses", force: :cascade do |t|
    t.bigint "case_contact_id", null: false
    t.decimal "other_expense_amount"
    t.string "other_expenses_describe"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_contact_id"], name: "index_additional_expenses_on_case_contact_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "content"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "all_casa_admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.index ["email"], name: "index_all_casa_admins_on_email", unique: true
    t.index ["invitation_token"], name: "index_all_casa_admins_on_invitation_token", unique: true
    t.index ["reset_password_token"], name: "index_all_casa_admins_on_reset_password_token", unique: true
  end

  create_table "banners", force: :cascade do |t|
    t.bigint "casa_org_id", null: false
    t.bigint "user_id", null: false
    t.string "name"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["casa_org_id"], name: "index_banners_on_casa_org_id"
    t.index ["user_id"], name: "index_banners_on_user_id"
  end

  create_table "casa_case_contact_types", force: :cascade do |t|
    t.bigint "contact_type_id", null: false
    t.bigint "casa_case_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["casa_case_id"], name: "index_casa_case_contact_types_on_casa_case_id"
    t.index ["contact_type_id"], name: "index_casa_case_contact_types_on_contact_type_id"
  end

  create_table "casa_case_emancipation_categories", force: :cascade do |t|
    t.bigint "casa_case_id", null: false
    t.bigint "emancipation_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["casa_case_id"], name: "index_casa_case_emancipation_categories_on_casa_case_id"
    t.index ["emancipation_category_id"], name: "index_case_emancipation_categories_on_emancipation_category_id"
  end

  create_table "casa_cases", force: :cascade do |t|
    t.string "case_number", null: false
    t.boolean "transition_aged_youth", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "casa_org_id", null: false
    t.datetime "birth_month_year_youth", precision: nil
    t.datetime "court_report_due_date", precision: nil
    t.bigint "hearing_type_id"
    t.boolean "active", default: true, null: false
    t.bigint "judge_id"
    t.datetime "court_report_submitted_at", precision: nil
    t.integer "court_report_status", default: 0
    t.string "slug"
    t.datetime "date_in_care"
    t.index ["casa_org_id"], name: "index_casa_cases_on_casa_org_id"
    t.index ["case_number", "casa_org_id"], name: "index_casa_cases_on_case_number_and_casa_org_id", unique: true
    t.index ["hearing_type_id"], name: "index_casa_cases_on_hearing_type_id"
    t.index ["judge_id"], name: "index_casa_cases_on_judge_id"
    t.index ["slug"], name: "index_casa_cases_on_slug"
  end

  create_table "casa_cases_emancipation_options", force: :cascade do |t|
    t.bigint "casa_case_id", null: false
    t.bigint "emancipation_option_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["casa_case_id", "emancipation_option_id"], name: "index_cases_options_on_case_id_and_option_id", unique: true
  end

  create_table "casa_orgs", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name"
    t.string "address"
    t.string "footer_links", default: [], array: true
    t.string "slug"
    t.boolean "show_driving_reimbursement", default: true
    t.boolean "show_fund_request", default: false
    t.string "twilio_phone_number"
    t.string "twilio_account_sid"
    t.string "twilio_api_key_sid"
    t.string "twilio_api_key_secret"
    t.boolean "twilio_enabled", default: false
    t.boolean "additional_expenses_enabled", default: false
    t.index ["slug"], name: "index_casa_orgs_on_slug", unique: true
  end

  create_table "case_assignments", force: :cascade do |t|
    t.bigint "casa_case_id", null: false
    t.bigint "volunteer_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hide_old_contacts", default: false
    t.boolean "allow_reimbursement", default: true
    t.index ["casa_case_id"], name: "index_case_assignments_on_casa_case_id"
    t.index ["volunteer_id"], name: "index_case_assignments_on_volunteer_id"
  end

  create_table "case_contact_contact_types", force: :cascade do |t|
    t.bigint "case_contact_id", null: false
    t.bigint "contact_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_contact_id"], name: "index_case_contact_contact_types_on_case_contact_id"
    t.index ["contact_type_id"], name: "index_case_contact_contact_types_on_contact_type_id"
  end

  create_table "case_contacts", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.bigint "casa_case_id", null: false
    t.integer "duration_minutes", null: false
    t.datetime "occurred_at", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "contact_made", default: false
    t.string "medium_type"
    t.integer "miles_driven", default: 0, null: false
    t.boolean "want_driving_reimbursement", default: false
    t.string "notes"
    t.datetime "deleted_at", precision: nil
    t.boolean "reimbursement_complete", default: false
    t.index ["casa_case_id"], name: "index_case_contacts_on_casa_case_id"
    t.index ["creator_id"], name: "index_case_contacts_on_creator_id"
    t.index ["deleted_at"], name: "index_case_contacts_on_deleted_at"
    t.check_constraint "miles_driven IS NOT NULL OR NOT want_driving_reimbursement", name: "want_driving_reimbursement_only_when_miles_driven"
  end

  create_table "case_court_orders", force: :cascade do |t|
    t.bigint "casa_case_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "implementation_status"
    t.bigint "court_date_id"
    t.string "text"
    t.index ["casa_case_id"], name: "index_case_court_orders_on_casa_case_id"
    t.index ["court_date_id"], name: "index_case_court_orders_on_court_date_id"
  end

  create_table "checklist_items", force: :cascade do |t|
    t.integer "hearing_type_id"
    t.text "description", null: false
    t.string "category", null: false
    t.boolean "mandatory", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hearing_type_id"], name: "index_checklist_items_on_hearing_type_id"
  end

  create_table "contact_type_groups", force: :cascade do |t|
    t.bigint "casa_org_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.index ["casa_org_id"], name: "index_contact_type_groups_on_casa_org_id"
  end

  create_table "contact_types", force: :cascade do |t|
    t.bigint "contact_type_group_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.index ["contact_type_group_id"], name: "index_contact_types_on_contact_type_group_id"
  end

  create_table "court_dates", force: :cascade do |t|
    t.datetime "date", precision: nil, null: false
    t.bigint "casa_case_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "hearing_type_id"
    t.bigint "judge_id"
    t.datetime "court_report_due_date", precision: nil
    t.index ["casa_case_id"], name: "index_court_dates_on_casa_case_id"
    t.index ["hearing_type_id"], name: "index_court_dates_on_hearing_type_id"
    t.index ["judge_id"], name: "index_court_dates_on_judge_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "emancipation_categories", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "mutually_exclusive", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_emancipation_categories_on_name", unique: true
  end

  create_table "emancipation_options", force: :cascade do |t|
    t.bigint "emancipation_category_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["emancipation_category_id", "name"], name: "index_emancipation_options_on_emancipation_category_id_and_name", unique: true
    t.index ["emancipation_category_id"], name: "index_emancipation_options_on_emancipation_category_id"
  end

  create_table "feature_flags", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_feature_flags_on_name", unique: true
  end

  create_table "followups", force: :cascade do |t|
    t.bigint "case_contact_id"
    t.bigint "creator_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "note"
    t.index ["case_contact_id"], name: "index_followups_on_case_contact_id"
    t.index ["creator_id"], name: "index_followups_on_creator_id"
  end

  create_table "fund_requests", force: :cascade do |t|
    t.text "submitter_email"
    t.text "youth_name"
    t.text "payment_amount"
    t.text "deadline"
    t.text "request_purpose"
    t.text "payee_name"
    t.text "requested_by_and_relationship"
    t.text "other_funding_source_sought"
    t.text "impact"
    t.text "extra_information"
    t.text "timestamps"
  end

  create_table "healths", force: :cascade do |t|
    t.datetime "latest_deploy_time", precision: nil
    t.integer "singleton_guard"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["singleton_guard"], name: "index_healths_on_singleton_guard", unique: true
  end

  create_table "hearing_types", force: :cascade do |t|
    t.bigint "casa_org_id", null: false
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.string "checklist_updated_date", default: "None", null: false
    t.index ["casa_org_id"], name: "index_hearing_types_on_casa_org_id"
  end

  create_table "judges", force: :cascade do |t|
    t.bigint "casa_org_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.string "name"
    t.index ["casa_org_id"], name: "index_judges_on_casa_org_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name"
    t.bigint "casa_org_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["casa_org_id"], name: "index_languages_on_casa_org_id"
  end

  create_table "languages_users", id: false, force: :cascade do |t|
    t.bigint "language_id", null: false
    t.bigint "user_id", null: false
    t.index ["language_id"], name: "index_languages_users_on_language_id"
    t.index ["user_id"], name: "index_languages_users_on_user_id"
  end

  create_table "learning_hour_types", force: :cascade do |t|
    t.bigint "casa_org_id", null: false
    t.string "name"
    t.boolean "active", default: true
    t.integer "position", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["casa_org_id"], name: "index_learning_hour_types_on_casa_org_id"
  end

  create_table "learning_hours", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "learning_type", default: 5
    t.string "name", null: false
    t.integer "duration_minutes", null: false
    t.integer "duration_hours", null: false
    t.datetime "occurred_at", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "learning_hour_type_id"
    t.index ["learning_hour_type_id"], name: "index_learning_hours_on_learning_hour_type_id"
    t.index ["user_id"], name: "index_learning_hours_on_user_id"
  end

  create_table "mileage_rates", force: :cascade do |t|
    t.decimal "amount"
    t.date "effective_date"
    t.boolean "is_active", default: true
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "casa_org_id", null: false
    t.index ["casa_org_id"], name: "index_mileage_rates_on_casa_org_id"
    t.index ["user_id"], name: "index_mileage_rates_on_user_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "content"
    t.bigint "creator_id"
    t.string "notable_type"
    t.bigint "notable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notable_type", "notable_id"], name: "index_notes_on_notable"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.string "type", null: false
    t.jsonb "params"
    t.datetime "read_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "other_duties", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.string "creator_type"
    t.datetime "occurred_at", precision: nil
    t.bigint "duration_minutes"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patch_note_groups", force: :cascade do |t|
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["value"], name: "index_patch_note_groups_on_value", unique: true
  end

  create_table "patch_note_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_patch_note_types_on_name", unique: true
  end

  create_table "patch_notes", force: :cascade do |t|
    t.text "note", null: false
    t.bigint "patch_note_type_id", null: false
    t.bigint "patch_note_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patch_note_group_id"], name: "index_patch_notes_on_patch_note_group_id"
    t.index ["patch_note_type_id"], name: "index_patch_notes_on_patch_note_type_id"
  end

  create_table "placement_types", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "casa_org_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["casa_org_id"], name: "index_placement_types_on_casa_org_id"
  end

  create_table "placements", force: :cascade do |t|
    t.datetime "placement_started_at", null: false
    t.bigint "placement_type_id", null: false
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "casa_case_id", null: false
    t.index ["casa_case_id"], name: "index_placements_on_casa_case_id"
    t.index ["creator_id"], name: "index_placements_on_creator_id"
    t.index ["placement_type_id"], name: "index_placements_on_placement_type_id"
  end

  create_table "preference_sets", force: :cascade do |t|
    t.bigint "user_id"
    t.jsonb "case_volunteer_columns", default: "{}", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "table_state", default: {}
    t.index ["user_id"], name: "index_preference_sets_on_user_id"
  end

  create_table "sent_emails", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "casa_org_id", null: false
    t.string "mailer_type"
    t.string "category"
    t.string "sent_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["casa_org_id"], name: "index_sent_emails_on_casa_org_id"
    t.index ["user_id"], name: "index_sent_emails_on_user_id"
  end

  create_table "sms_notification_events", force: :cascade do |t|
    t.string "name"
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "supervisor_volunteers", force: :cascade do |t|
    t.bigint "supervisor_id", null: false
    t.bigint "volunteer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true
    t.index ["supervisor_id"], name: "index_supervisor_volunteers_on_supervisor_id"
    t.index ["volunteer_id"], name: "index_supervisor_volunteers_on_volunteer_id"
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  create_table "user_languages", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "language_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id", "user_id"], name: "index_user_languages_on_language_id_and_user_id", unique: true
    t.index ["language_id"], name: "index_user_languages_on_language_id"
    t.index ["user_id"], name: "index_user_languages_on_user_id"
  end

  create_table "user_reminder_times", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "case_contact_types"
    t.datetime "no_contact_made"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_reminder_times_on_user_id"
  end

  create_table "user_sms_notification_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "sms_notification_event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sms_notification_event_id"], name: "index_user_sms_notification_events_on_sms_notification_event_id"
    t.index ["user_id"], name: "index_user_sms_notification_events_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "casa_org_id", null: false
    t.string "display_name", default: "", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "type"
    t.boolean "active", default: true
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "phone_number", default: ""
    t.boolean "receive_sms_notifications", default: false, null: false
    t.boolean "receive_email_notifications", default: true
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "old_emails", default: [], array: true
    t.boolean "receive_reimbursement_email", default: false
    t.index ["casa_org_id"], name: "index_users_on_casa_org_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "additional_expenses", "case_contacts"
  add_foreign_key "addresses", "users"
  add_foreign_key "banners", "casa_orgs"
  add_foreign_key "banners", "users"
  add_foreign_key "casa_case_emancipation_categories", "casa_cases"
  add_foreign_key "casa_case_emancipation_categories", "emancipation_categories"
  add_foreign_key "casa_cases", "casa_orgs"
  add_foreign_key "casa_cases_emancipation_options", "casa_cases"
  add_foreign_key "casa_cases_emancipation_options", "emancipation_options"
  add_foreign_key "case_assignments", "casa_cases"
  add_foreign_key "case_assignments", "users", column: "volunteer_id"
  add_foreign_key "case_contacts", "casa_cases"
  add_foreign_key "case_contacts", "users", column: "creator_id"
  add_foreign_key "case_court_orders", "casa_cases"
  add_foreign_key "court_dates", "casa_cases"
  add_foreign_key "emancipation_options", "emancipation_categories"
  add_foreign_key "followups", "users", column: "creator_id"
  add_foreign_key "judges", "casa_orgs"
  add_foreign_key "languages", "casa_orgs"
  add_foreign_key "learning_hour_types", "casa_orgs"
  add_foreign_key "learning_hours", "learning_hour_types"
  add_foreign_key "learning_hours", "users"
  add_foreign_key "mileage_rates", "casa_orgs"
  add_foreign_key "mileage_rates", "users"
  add_foreign_key "notes", "users", column: "creator_id"
  add_foreign_key "other_duties", "users", column: "creator_id"
  add_foreign_key "patch_notes", "patch_note_groups"
  add_foreign_key "patch_notes", "patch_note_types"
  add_foreign_key "placement_types", "casa_orgs"
  add_foreign_key "placements", "placement_types"
  add_foreign_key "placements", "users", column: "creator_id"
  add_foreign_key "preference_sets", "users"
  add_foreign_key "sent_emails", "casa_orgs"
  add_foreign_key "sent_emails", "users"
  add_foreign_key "supervisor_volunteers", "users", column: "supervisor_id"
  add_foreign_key "supervisor_volunteers", "users", column: "volunteer_id"
  add_foreign_key "user_reminder_times", "users"
  add_foreign_key "user_sms_notification_events", "sms_notification_events"
  add_foreign_key "user_sms_notification_events", "users"
  add_foreign_key "users", "casa_orgs"
end
