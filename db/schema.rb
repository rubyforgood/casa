# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_05_192934) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "all_casa_admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_all_casa_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_all_casa_admins_on_reset_password_token", unique: true
  end

  create_table "casa_cases", force: :cascade do |t|
    t.string "case_number", null: false
    t.boolean "transition_aged_youth", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "casa_org_id", null: false
    t.index ["casa_org_id"], name: "index_casa_cases_on_casa_org_id"
    t.index ["case_number"], name: "index_casa_cases_on_case_number", unique: true
  end

  create_table "casa_orgs", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "case_assignments", force: :cascade do |t|
    t.bigint "casa_case_id", null: false
    t.bigint "volunteer_id", null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["casa_case_id"], name: "index_case_assignments_on_casa_case_id"
    t.index ["volunteer_id"], name: "index_case_assignments_on_volunteer_id"
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
    t.string "contact_types", array: true
    t.integer "miles_driven"
    t.boolean "want_driving_reimbursement", default: false
    t.string "notes"
    t.index ["casa_case_id"], name: "index_case_contacts_on_casa_case_id"
    t.index ["contact_types"], name: "index_case_contacts_on_contact_types", using: :gin
    t.index ["creator_id"], name: "index_case_contacts_on_creator_id"
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

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "casa_org_id", null: false
    t.string "display_name", default: ""
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
    t.index ["casa_org_id"], name: "index_users_on_casa_org_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "casa_cases", "casa_orgs"
  add_foreign_key "case_assignments", "casa_cases"
  add_foreign_key "case_assignments", "users", column: "volunteer_id"
  add_foreign_key "case_contacts", "casa_cases"
  add_foreign_key "case_contacts", "users", column: "creator_id"
  add_foreign_key "supervisor_volunteers", "users", column: "supervisor_id"
  add_foreign_key "supervisor_volunteers", "users", column: "volunteer_id"
  add_foreign_key "users", "casa_orgs"
end
