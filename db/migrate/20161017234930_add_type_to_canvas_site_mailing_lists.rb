class AddTypeToCanvasSiteMailingLists < ActiveRecord::Migration
  def change
    add_column :canvas_site_mailing_lists, :type, :string

    # All lists created pre-migration are of the CalmailList type.
    reversible do |dir|
      dir.up do
        MailingLists::SiteMailingList.update_all type: 'MailingLists::CalmailList'
      end
      dir.down do
        # The column should be dropped.
      end
    end
  end
end
