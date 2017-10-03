class WebcastPreferencesUniqueIndex < ActiveRecord::Migration
  def up
    remove_index(:webcast_preferences, name: 'webcast_preferences_main_index')
    add_index(:webcast_preferences, [:year, :term_cd, :ccn], {unique: true, name: 'webcast_preferences_unique_index'})
  end

  def down
    remove_index(:webcast_preferences, name: 'webcast_preferences_unique_index')
    add_index(:webcast_preferences, [:year, :term_cd, :ccn], {name: 'webcast_preferences_main_index'})
  end
end
