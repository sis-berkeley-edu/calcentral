class ChangeFinAidYears < ActiveRecord::Migration

  class FinAidYearMigrationModel < ApplicationRecord
    self.table_name = 'fin_aid_years'
  end

  def up
    if (row = FinAidYearMigrationModel.find_by(current_year: 2015))
      row.update_attribute(:upcoming_start_date, Date.new(2015, 4, 25))
    end
    FinAidYearMigrationModel.where('current_year > 2015').each do |row2|
      row2.update_attribute(:upcoming_start_date, Date.new(row.current_year, 5, 1))
    end
  end

  def down
  end
end
