class DropSummerSubTerm < ActiveRecord::Migration
  class SummerSubTermMigrationModel < ActiveRecord::Base
    attr_accessible :year, :sub_term_code, :start, :end
    self.table_name = 'summer_sub_terms'
  end

  def up
    drop_table :summer_sub_terms
  end

  def down
    create_table :summer_sub_terms do |t|
      t.integer :year, null: false
      t.integer :sub_term_code, null: false
      t.date :start, null: false
      t.date :end, null: false
      t.timestamps
    end

    change_table :summer_sub_terms do |t|
      t.index [:year, :sub_term_code]
    end

    # 2017 summer subterms
    SummerSubTermMigrationModel.create(
      year: 2017, sub_term_code: 5, start: Date.new(2017, 5, 22), end: Date.new(2017, 6, 30))
    SummerSubTermMigrationModel.create(
      year: 2017, sub_term_code: 8, start: Date.new(2017, 6, 5), end: Date.new(2017, 8, 11))
    SummerSubTermMigrationModel.create(
      year: 2017, sub_term_code: 7, start: Date.new(2017, 6, 19), end: Date.new(2017, 8, 11))
    SummerSubTermMigrationModel.create(
      year: 2017, sub_term_code: 6, start: Date.new(2017, 7, 3), end: Date.new(2017, 8, 11))
    SummerSubTermMigrationModel.create(
      year: 2017, sub_term_code: 9, start: Date.new(2017, 7, 24), end: Date.new(2017, 8, 11))

    # 2018 summer subterms
    SummerSubTermMigrationModel.create(
      year: 2018, sub_term_code: 5, start: Date.new(2018, 5, 21), end: Date.new(2018, 6, 29))
    SummerSubTermMigrationModel.create(
      year: 2018, sub_term_code: 8, start: Date.new(2018, 6, 4), end: Date.new(2018, 8, 10))
    SummerSubTermMigrationModel.create(
      year: 2018, sub_term_code: 7, start: Date.new(2018, 6, 18), end: Date.new(2018, 8, 10))
    SummerSubTermMigrationModel.create(
      year: 2018, sub_term_code: 6, start: Date.new(2018, 7, 2), end: Date.new(2018, 8, 10))
    SummerSubTermMigrationModel.create(
      year: 2018, sub_term_code: 9, start: Date.new(2018, 7, 23), end: Date.new(2018, 8, 10))
  end
end
