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

ActiveRecord::Schema.define(version: 2020_04_17_192341) do

  create_table "ps_uc_clc_oauth", primary_key: "uc_clc_id", force: :cascade do |t|
    t.string "uc_clc_ldap_uid", limit: 255
    t.text "access_token"
    t.text "refresh_token"
    t.integer "expiration_time", limit: 8
    t.text "app_data"
    t.index ["uc_clc_ldap_uid"], name: "index_ps_uc_clc_oauth_on_uid_app_id", unique: true
  end

  create_table "ps_uc_clc_srvalert", primary_key: "uc_clc_id", force: :cascade do |t|
    t.string "uc_alrt_title", limit: 255, null: false
    t.text "uc_alrt_snippt"
    t.text "uc_alrt_body", null: false
    t.datetime "uc_alrt_pubdt", null: false
    t.boolean "uc_alrt_display", default: false, null: false
    t.boolean "uc_alrt_splash", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["uc_alrt_display", "created_at"], name: "index_Pps_uc_clc_srvalert_on_display_and_created_at"
  end

  create_table "ps_uc_recent_uids", primary_key: "uc_clc_id", force: :cascade do |t|
    t.string "uc_clc_oid", limit: 255
    t.string "uc_clc_stor_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["uc_clc_oid"], name: "ps_uc_recent_uids_index"
  end

  create_table "ps_uc_saved_uids", primary_key: "uc_clc_id", force: :cascade do |t|
    t.string "uc_clc_oid", limit: 255
    t.string "uc_clc_stor_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["uc_clc_oid"], name: "ps_uc_saved_uids_index"
  end

  create_table "ps_uc_user_auths", primary_key: "uc_clc_id", force: :cascade do |t|
    t.string "uc_clc_ldap_uid", limit: 255, null: false
    t.boolean "uc_clc_is_su", default: false, null: false
    t.boolean "uc_clc_active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "uc_clc_is_au", default: false, null: false
    t.boolean "uc_clc_is_vw", default: false, null: false
    t.index ["uc_clc_ldap_uid"], name: "index_ps_uc_user_auths_on_uid", unique: true
  end

  create_table "ps_uc_user_data", primary_key: "uc_clc_id", force: :cascade do |t|
    t.string "uc_clc_ldap_uid", limit: 255
    t.string "uc_clc_prefnm", limit: 255
    t.datetime "uc_clc_fst_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uc_clc_ldap_uid"], name: "index_ps_uc_user_data_on_uid", unique: true
  end

  create_table "schema_migrations_backup", id: false, force: :cascade do |t|
    t.string "version", limit: 255
  end

  create_table "schema_migrations_fixed_backup", id: false, force: :cascade do |t|
    t.string "version", limit: 255
  end

end
