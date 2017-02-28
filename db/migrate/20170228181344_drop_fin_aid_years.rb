class DropFinAidYears < ActiveRecord::Migration
  def up
    drop_table :fin_aid_years
  end

  def down
    create_table :fin_aid_years do |t|
      t.integer :current_year, null:false
      t.date :upcoming_start_date, null:false
      t.timestamps
    end
    change_table :fin_aid_years do |t|
      t.index [:current_year], unique: true
    end
  end
end
