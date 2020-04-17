class RemoveAppIdFromOauth2Data < ActiveRecord::Migration[6.0]
  def up
    remove_column :ps_uc_clc_oauth, :uc_clc_app_id
  end

  def down
    add_column :ps_uc_clc_oauth, :uc_clc_app_id, :string, default: 'Google', limit: 255
  end
end
