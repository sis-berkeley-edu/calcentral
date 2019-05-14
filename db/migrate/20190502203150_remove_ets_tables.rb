class RemoveEtsTables < ActiveRecord::Migration
  def up
    drop_table :canvas_site_mailing_list_members
    drop_table :canvas_site_mailing_lists
    drop_table :canvas_synchronization
    drop_table :webcast_course_site_log
  end

  def down
    create_table "canvas_site_mailing_list_members", force: :cascade do |t|
      t.integer  "mailing_list_id",                             null: false
      t.string   "first_name",      limit: 255
      t.string   "last_name",       limit: 255
      t.string   "email_address",   limit: 255,                 null: false
      t.boolean  "can_send",                    default: false, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "canvas_site_mailing_list_members", ["mailing_list_id", "email_address"], name: "mailing_list_membership_index", unique: true, using: :btree

    create_table "canvas_site_mailing_lists", force: :cascade do |t|
      t.string   "canvas_site_id",         limit: 255
      t.string   "canvas_site_name",       limit: 255
      t.string   "list_name",              limit: 255
      t.string   "state",                  limit: 255
      t.datetime "populated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "members_count"
      t.integer  "populate_add_errors"
      t.integer  "populate_remove_errors"
      t.string   "type",                   limit: 255
    end
    add_index "canvas_site_mailing_lists", ["canvas_site_id"], name: "index_canvas_site_mailing_lists_on_canvas_site_id", unique: true, using: :btree

    create_table "canvas_synchronization", force: :cascade do |t|
      t.datetime "last_guest_user_sync"
      t.datetime "latest_term_enrollment_csv_set"
    end

    create_table "webcast_course_site_log", force: :cascade do |t|
      t.integer  "canvas_course_site_id",    null: false
      t.datetime "webcast_tool_unhidden_at", null: false
      t.datetime "created_at",               null: false
      t.datetime "updated_at",               null: false
    end
    add_index "webcast_course_site_log", ["canvas_course_site_id"], name: "webcast_course_site_log_unique_index", unique: true, using: :btree
  end
end
