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

ActiveRecord::Schema.define(version: 2021_10_25_143709) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "all_casa_admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.index ["email"], name: "index_all_casa_admins_on_email", unique: true
    t.index ["invitation_token"], name: "index_all_casa_admins_on_invitation_token", unique: true
    t.index ["reset_password_token"], name: "index_all_casa_admins_on_reset_password_token", unique: true
  end

  create_table "casa_case_contact_types", force: :cascade do |t|
    t.bigint "contact_type_id", null: false
    t.bigint "casa_case_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["casa_case_id"], name: "index_casa_case_contact_types_on_casa_case_id"
    t.index ["contact_type_id"], name: "index_casa_case_contact_types_on_contact_type_id"
  end

  create_table "casa_case_emancipation_categories", force: :cascade do |t|
    t.bigint "casa_case_id", null: false
    t.bigint "emancipation_category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["casa_case_id"], name: "index_casa_case_emancipation_categories_on_casa_case_id"
    t.index ["emancipation_category_id"], name: "index_case_emancipation_categories_on_emancipation_category_id"
  end

  create_table "casa_cases", force: :cascade do |t|
    t.string "case_number", null: false
    t.boolean "transition_aged_youth", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "casa_org_id", null: false
    t.datetime "birth_month_year_youth"
    t.datetime "court_date"
    t.datetime "court_report_due_date"
    t.bigint "hearing_type_id"
    t.boolean "active", default: true, null: false
    t.bigint "judge_id"
    t.datetime "court_report_submitted_at"
    t.integer "court_report_status", default: 0
    t.string "slug"
    t.index ["casa_org_id"], name: "index_casa_cases_on_casa_org_id"
    t.index ["case_number", "casa_org_id"], name: "index_casa_cases_on_case_number_and_casa_org_id", unique: true
    t.index ["hearing_type_id"], name: "index_casa_cases_on_hearing_type_id"
    t.index ["judge_id"], name: "index_casa_cases_on_judge_id"
    t.index ["slug"], name: "index_casa_cases_on_slug"
  end

  create_table "casa_cases_emancipation_options", force: :cascade do |t|
    t.bigint "casa_case_id", null: false
    t.bigint "emancipation_option_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["casa_case_id", "emancipation_option_id"], name: "index_cases_options_on_case_id_and_option_id", unique: true
  end

  create_table "casa_orgs", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "display_name"
    t.string "address"
    t.string "footer_links", default: [], array: true
    t.string "slug"
    t.boolean "show_driving_reimbursement", default: true
    t.index ["slug"], name: "index_casa_orgs_on_slug", unique: true
  end

  create_table "case_assignments", force: :cascade do |t|
    t.bigint "casa_case_id", null: false
    t.bigint "volunteer_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["casa_case_id"], name: "index_case_assignments_on_casa_case_id"
    t.index ["volunteer_id"], name: "index_case_assignments_on_volunteer_id"
  end

  create_table "case_contact_contact_types", force: :cascade do |t|
    t.bigint "case_contact_id", null: false
    t.bigint "contact_type_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["case_contact_id"], name: "index_case_contact_contact_types_on_case_contact_id"
    t.index ["contact_type_id"], name: "index_case_contact_contact_types_on_contact_type_id"
  end

  create_table "case_contacts", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.bigint "casa_case_id", null: false
    t.integer "duration_minutes", null: false
    t.datetime "occurred_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "contact_made", default: false
    t.string "medium_type"
    t.integer "miles_driven", default: 0, null: false
    t.boolean "want_driving_reimbursement", default: false
    t.string "notes"
    t.datetime "deleted_at"
    t.index ["casa_case_id"], name: "index_case_contacts_on_casa_case_id"
    t.index ["creator_id"], name: "index_case_contacts_on_creator_id"
    t.index ["deleted_at"], name: "index_case_contacts_on_deleted_at"
    t.check_constraint "(miles_driven IS NOT NULL) OR (NOT want_driving_reimbursement)", name: "want_driving_reimbursement_only_when_miles_driven"
  end

  create_table "case_court_orders", force: :cascade do |t|
    t.bigint "casa_case_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "implementation_status"
    t.bigint "court_date_id"
    t.string "text"
    t.index ["casa_case_id"], name: "index_case_court_orders_on_casa_case_id"
    t.index ["court_date_id"], name: "index_case_court_orders_on_court_date_id"
  end

  create_table "contact_type_groups", force: :cascade do |t|
    t.bigint "casa_org_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active", default: true
    t.index ["casa_org_id"], name: "index_contact_type_groups_on_casa_org_id"
  end

  create_table "contact_types", force: :cascade do |t|
    t.bigint "contact_type_group_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active", default: true
    t.index ["contact_type_group_id"], name: "index_contact_types_on_contact_type_group_id"
  end

  create_table "court_dates", force: :cascade do |t|
    t.datetime "date", null: false
    t.bigint "casa_case_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "hearing_type_id"
    t.bigint "judge_id"
    t.index ["casa_case_id"], name: "index_court_dates_on_casa_case_id"
    t.index ["hearing_type_id"], name: "index_court_dates_on_hearing_type_id"
    t.index ["judge_id"], name: "index_court_dates_on_judge_id"
  end

  create_table "emancipation_categories", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "mutually_exclusive", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_emancipation_categories_on_name", unique: true
  end

  create_table "emancipation_options", force: :cascade do |t|
    t.bigint "emancipation_category_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["emancipation_category_id", "name"], name: "index_emancipation_options_on_emancipation_category_id_and_name", unique: true
    t.index ["emancipation_category_id"], name: "index_emancipation_options_on_emancipation_category_id"
  end

  create_table "followups", force: :cascade do |t|
    t.bigint "case_contact_id"
    t.bigint "creator_id"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "note"
    t.index ["case_contact_id"], name: "index_followups_on_case_contact_id"
    t.index ["creator_id"], name: "index_followups_on_creator_id"
  end

  create_table "healths", force: :cascade do |t|
    t.datetime "latest_deploy_time"
    t.integer "singleton_guard"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["singleton_guard"], name: "index_healths_on_singleton_guard", unique: true
  end

  create_table "hearing_types", force: :cascade do |t|
    t.bigint "casa_org_id", null: false
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.index ["casa_org_id"], name: "index_hearing_types_on_casa_org_id"
  end

  create_table "judges", force: :cascade do |t|
    t.bigint "casa_org_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active", default: true
    t.string "name"
    t.index ["casa_org_id"], name: "index_judges_on_casa_org_id"
  end

  create_table "mileage_rates", force: :cascade do |t|
    t.decimal "amount"
    t.date "effective_date"
    t.boolean "is_active", default: true
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_mileage_rates_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.string "type", null: false
    t.jsonb "params"
    t.datetime "read_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "preference_sets", force: :cascade do |t|
    t.bigint "user_id"
    t.jsonb "case_volunteer_columns", default: "{}", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_preference_sets_on_user_id"
  end

  create_table "sent_emails", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "casa_org_id", null: false
    t.string "mailer_type"
    t.string "category"
    t.string "sent_address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["casa_org_id"], name: "index_sent_emails_on_casa_org_id"
    t.index ["user_id"], name: "index_sent_emails_on_user_id"
  end

  create_table "supervisor_volunteers", force: :cascade do |t|
    t.bigint "supervisor_id", null: false
    t.bigint "volunteer_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_active", default: true
    t.index ["supervisor_id"], name: "index_supervisor_volunteers_on_supervisor_id"
    t.index ["volunteer_id"], name: "index_supervisor_volunteers_on_volunteer_id"
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "casa_org_id", null: false
    t.string "display_name", default: "", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "type"
    t.boolean "active", default: true
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["casa_org_id"], name: "index_users_on_casa_org_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type"
    t.string "{:null=>false}"
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
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
  add_foreign_key "mileage_rates", "users"
  add_foreign_key "preference_sets", "users"
  add_foreign_key "sent_emails", "casa_orgs"
  add_foreign_key "sent_emails", "users"
  add_foreign_key "supervisor_volunteers", "users", column: "supervisor_id"
  add_foreign_key "supervisor_volunteers", "users", column: "volunteer_id"
  add_foreign_key "users", "casa_orgs"
end
