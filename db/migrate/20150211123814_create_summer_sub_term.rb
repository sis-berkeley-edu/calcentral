class CreateSummerSubTerm < ActiveRecord::Migration

  class SummerSubTermMigrationModel < ActiveRecord::Base
    attr_accessible :year, :sub_term_code, :start, :end
    self.table_name = 'summer_sub_terms'
  end

  def change
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

    reversible do |dir|
      dir.up do
        # 2015 summer subterms
        SummerSubTermMigrationModel.create(
          year: 2015, sub_term_code: 5, start: Date.new(2015, 5, 26), end: Date.new(2015, 7, 2))
        SummerSubTermMigrationModel.create(
          year: 2015, sub_term_code: 8, start: Date.new(2015, 6, 8), end: Date.new(2015, 8, 14))
        SummerSubTermMigrationModel.create(
          year: 2015, sub_term_code: 7, start: Date.new(2015, 6, 22), end: Date.new(2015, 8, 14))
        SummerSubTermMigrationModel.create(
          year: 2015, sub_term_code: 6, start: Date.new(2015, 7, 6), end: Date.new(2015, 8, 14))
        SummerSubTermMigrationModel.create(
          year: 2015, sub_term_code: 9, start: Date.new(2015, 7, 27), end: Date.new(2015, 8, 14))

        # 2016 summer subterms
        SummerSubTermMigrationModel.create(
          year: 2016, sub_term_code: 5, start: Date.new(2016, 5, 23), end: Date.new(2016, 7, 1))
        SummerSubTermMigrationModel.create(
          year: 2016, sub_term_code: 8, start: Date.new(2016, 6, 6), end: Date.new(2016, 8, 12))
        SummerSubTermMigrationModel.create(
          year: 2016, sub_term_code: 7, start: Date.new(2016, 6, 20), end: Date.new(2016, 8, 12))
        SummerSubTermMigrationModel.create(
          year: 2016, sub_term_code: 6, start: Date.new(2016, 7, 5), end: Date.new(2016, 8, 12))
        SummerSubTermMigrationModel.create(
          year: 2016, sub_term_code: 9, start: Date.new(2016, 7, 25), end: Date.new(2016, 8, 12))

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
      dir.down do
        # All rows should be dropped.
      end
    end
  end
end
