class RemoveCampusLinkTables < ActiveRecord::Migration[4.2]
  def up
    drop_table :links if ActiveRecord::Base.connection.table_exists? 'links'
    drop_table :user_roles if ActiveRecord::Base.connection.table_exists? 'user_roles'
    drop_table :links_user_roles if ActiveRecord::Base.connection.table_exists? 'links_user_roles'
    drop_table :link_sections if ActiveRecord::Base.connection.table_exists? 'link_sections'
    drop_table :link_sections_links if ActiveRecord::Base.connection.table_exists? 'link_sections_links'
    drop_table :link_categories if ActiveRecord::Base.connection.table_exists? 'link_categories'
    drop_table :link_categories_link_sections if ActiveRecord::Base.connection.table_exists? 'link_categories_link_sections'
  end

  def down
    unless ActiveRecord::Base.connection.table_exists? 'link_categories'
      create_table "link_categories", force: :cascade do |t|
        t.string   "name",       limit: 255,                 null: false
        t.string   "slug",       limit: 255,                 null: false
        t.boolean  "root_level",             default: false
        t.datetime "created_at",                             null: false
        t.datetime "updated_at",                             null: false
      end
    end

    unless ActiveRecord::Base.connection.table_exists? 'link_categories_link_sections'
      create_table "link_categories_link_sections", id: false, force: :cascade do |t|
        t.integer "link_category_id"
        t.integer "link_section_id"
      end
    end

    unless ActiveRecord::Base.connection.table_exists? 'link_sections'
      create_table "link_sections", force: :cascade do |t|
        t.integer  "link_root_cat_id"
        t.integer  "link_top_cat_id"
        t.integer  "link_sub_cat_id"
        t.datetime "created_at",       null: false
        t.datetime "updated_at",       null: false
      end
    end

    unless ActiveRecord::Base.connection.table_exists? 'link_sections_links'
      create_table "link_sections_links", id: false, force: :cascade do |t|
        t.integer "link_section_id"
        t.integer "link_id"
      end
    end


    unless ActiveRecord::Base.connection.table_exists? 'links'
      create_table "links", force: :cascade do |t|
        t.string   "name",        limit: 255
        t.string   "url",         limit: 255
        t.string   "description", limit: 255
        t.boolean  "published",               default: true
        t.datetime "created_at",                             null: false
        t.datetime "updated_at",                             null: false
      end
    end

    unless ActiveRecord::Base.connection.table_exists? 'links_user_roles'
      create_table "links_user_roles", id: false, force: :cascade do |t|
        t.integer "link_id"
        t.integer "user_role_id"
      end
    end

    unless ActiveRecord::Base.connection.table_exists? 'user_roles'
      create_table "user_roles", force: :cascade do |t|
        t.string "name", limit: 255
        t.string "slug", limit: 255
      end
    end
  end
end
