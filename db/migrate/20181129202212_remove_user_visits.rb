class RemoveUserVisits < ActiveRecord::Migration
  def up
    drop_table :user_visits
  end

  def down
    create_table :user_visits, :id => false do |t|
      t.string :uid, :null => false
      t.timestamp :last_visit_at, :null => false
    end

    change_table :user_visits do |t|
      t.index :uid, :unique => true
      t.index :last_visit_at
    end
  end
end
