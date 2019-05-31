class CreatePsUcSavedUids < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.class.name == 'ActiveRecord::ConnectionAdapters::SQLite3Adapter'
      create_table "ps_uc_clc_oauth", {force: :cascade, primary_key:'uc_clc_id'} do |t|
        t.string  "uc_clc_ldap_uid",             limit: 255
        t.string  "uc_clc_app_id",          limit: 255
        t.text    "access_token"
        t.text    "refresh_token"
        t.integer "expiration_time", limit: 8
        t.text    "app_data"
      end

      add_index "ps_uc_clc_oauth", ["uc_clc_ldap_uid", "uc_clc_app_id"], name: "index_ps_uc_clc_oauth_on_uid_app_id", unique: true, using: :btree

      create_table "ps_uc_recent_uids", {force: :cascade, primary_key:'uc_clc_id'} do |t|
        t.string   "uc_clc_oid",   limit: 255
        t.string   "uc_clc_stor_id", limit: 255
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      add_index "ps_uc_recent_uids", ["uc_clc_oid"], name: "ps_uc_recent_uids_index", using: :btree

      create_table "ps_uc_saved_uids", {force: :cascade, primary_key:'uc_clc_id'} do |t|
        t.string   "uc_clc_oid",   limit: 255
        t.string   "uc_clc_stor_id", limit: 255
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      add_index "ps_uc_saved_uids", ["uc_clc_oid"], name: "ps_uc_saved_uids_index", using: :btree


      create_table "ps_uc_clc_srvalert", {force: :cascade, primary_key: 'uc_clc_id'} do |t|
        t.string   "uc_alrt_title",            limit: 255,                 null: false
        t.text     "uc_alrt_snippt"
        t.text     "uc_alrt_body",                                         null: false
        t.datetime "uc_alrt_pubdt",                             null: false
        t.boolean  "uc_alrt_display",                      default: false, null: false
        t.boolean  "uc_alrt_splash",                       default: false, null: false
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      add_index "ps_uc_clc_srvalert", ["uc_alrt_display", "created_at"], name: "index_Pps_uc_clc_srvalert_on_display_and_created_at", using: :btree

      create_table "ps_uc_user_auths", {force: :cascade, primary_key: 'uc_clc_id'} do |t|
        t.string   "uc_clc_ldap_uid",          limit: 255,                 null: false
        t.boolean  "uc_clc_is_su",             default: false, null: false
        t.boolean  "uc_clc_active",                   default: false, null: false
        t.datetime "created_at",                               null: false
        t.datetime "updated_at",                               null: false
        t.boolean  "uc_clc_is_au",                default: false, null: false
        t.boolean  "uc_clc_is_vw",                default: false, null: false
      end

      add_index "ps_uc_user_auths", ["uc_clc_ldap_uid"], name: "index_ps_uc_user_auths_on_uid", unique: true, using: :btree

      create_table "ps_uc_user_data", {force: :cascade, primary_key:'uc_clc_id'} do |t|
        t.string   "uc_clc_ldap_uid",            limit: 255
        t.string   "uc_clc_prefnm", limit: 255
        t.datetime "uc_clc_fst_at"
        t.datetime "created_at",                 null: false
        t.datetime "updated_at",                 null: false
      end

      create_table "ps_uc_user_data", {force: :cascade, primary_key:'uc_clc_id'} do |t|
        t.string   "uc_clc_ldap_uid",            limit: 255
        t.string   "uc_clc_prefnm", limit: 255
        t.datetime "uc_clc_fst_at"
        t.datetime "created_at",                 null: false
        t.datetime "updated_at",                 null: false
      end

      add_index "ps_uc_user_data", ["uc_clc_ldap_uid"], name: "index_ps_uc_user_data_on_uid", unique: true, using: :btree

      drop_table :saved_uids
      drop_table :oauth2_data
      drop_table :recent_uids
      drop_table :service_alerts
      drop_table :user_auths
      drop_table :user_data

    end
  end

  def down
    if ActiveRecord::Base.connection.class.name == 'ActiveRecord::ConnectionAdapters::SQLite3Adapter'
      drop_table :ps_uc_saved_uids
      drop_table :ps_uc_clc_oauth
      drop_table :ps_uc_recent_uids
      drop_table :ps_uc_clc_srvalert
      drop_table :ps_uc_user_auths
      drop_table :ps_uc_user_data


      create_table "service_alerts", force: :cascade do |t|
        t.string   "title",            limit: 255,                 null: false
        t.text     "snippet"
        t.text     "body",                                         null: false
        t.datetime "publication_date",                             null: false
        t.boolean  "display",                      default: false, null: false
        t.boolean  "splash",                       default: false, null: false
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      add_index "service_alerts", ["display", "created_at"], name: "index_service_alerts_on_display_and_created_at", using: :btree

      create_table "user_auths", force: :cascade do |t|
        t.string   "uid",          limit: 255,                 null: false
        t.boolean  "is_superuser",             default: false, null: false
        t.boolean  "active",                   default: false, null: false
        t.datetime "created_at",                               null: false
        t.datetime "updated_at",                               null: false
        t.boolean  "is_author",                default: false, null: false
        t.boolean  "is_viewer",                default: false, null: false
      end

      add_index "user_auths", ["uid"], name: "index_user_auths_on_uid", unique: true, using: :btree

      create_table "user_data", force: :cascade do |t|
        t.string   "uid",            limit: 255
        t.string   "preferred_name", limit: 255
        t.datetime "first_login_at"
        t.datetime "created_at",                 null: false
        t.datetime "updated_at",                 null: false
      end

      add_index "user_data", ["uid"], name: "index_user_data_on_uid", unique: true, using: :btree

      create_table "recent_uids", force: :cascade do |t|
        t.string   "owner_id",   limit: 255
        t.string   "stored_uid", limit: 255
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      add_index "recent_uids", ["owner_id"], name: "recent_uids_index", using: :btree

      create_table "saved_uids", force: :cascade do |t|
        t.string   "owner_id",   limit: 255
        t.string   "stored_uid", limit: 255
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      add_index "saved_uids", ["owner_id"], name: "saved_uids_index", using: :btree

      create_table "oauth2_data", force: :cascade do |t|
        t.string  "uid",             limit: 255
        t.string  "app_id",          limit: 255
        t.text    "access_token"
        t.text    "refresh_token"
        t.integer "expiration_time", limit: 8
        t.text    "app_data"
      end

      add_index "oauth2_data", ["uid", "app_id"], name: "index_oauth2_data_on_uid_app_id", unique: true, using: :btree

    end
  end
end
