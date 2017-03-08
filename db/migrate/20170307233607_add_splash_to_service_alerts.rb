class AddSplashToServiceAlerts < ActiveRecord::Migration
  def change
    add_column :service_alerts, :splash, :boolean, null: false, default: false
  end
end
