class RemoveNotifications < ActiveRecord::Migration
  def up
    drop_table :notifications
  end

  def down
    create_table :notifications do |t|
      t.string :uid
      t.text :data
      t.text :translator
      t.datetime :occurred_at
      t.timestamps
    end

    change_table :notifications do |t|
      t.index :uid
      t.index :occurred_at
    end
  end
end
