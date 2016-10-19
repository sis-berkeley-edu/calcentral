class CreateCanvasSiteMailingListMembers < ActiveRecord::Migration
  def change
    create_table :canvas_site_mailing_list_members do |t|
      t.integer :mailing_list_id, null: false
      t.string :first_name
      t.string :last_name
      t.string :email_address, null: false
      t.boolean :can_send, null: false, default: false

      t.timestamps
    end

    add_index :canvas_site_mailing_list_members, [:mailing_list_id, :email_address], unique: true, name: 'mailing_list_membership_index'
  end
end
