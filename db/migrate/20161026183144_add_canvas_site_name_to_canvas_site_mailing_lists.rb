class AddCanvasSiteNameToCanvasSiteMailingLists < ActiveRecord::Migration
  def change
    add_column :canvas_site_mailing_lists, :canvas_site_name, :string
  end
end
