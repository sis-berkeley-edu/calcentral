class SeedCanvasSynchronization < ActiveRecord::Migration

  class CanvasSynchronizationMigrationModel < ActiveRecord::Base
    self.table_name = 'canvas_synchronization'
  end

  def up
    CanvasSynchronizationMigrationModel.create(:last_guest_user_sync => 1.weeks.ago.utc)
  end

  def down
    CanvasSynchronizationMigrationModel.delete_all
  end
end
