module MailingLists
  class Member < ApplicationRecord
    include ActiveRecordHelper
    include ClassLogger

    belongs_to :mailing_list, class_name: 'MailingLists::SiteMailingList', foreign_key: 'mailing_list_id'

    self.table_name = 'canvas_site_mailing_list_members'

    attr_accessible :first_name, :last_name, :email_address, :can_send, :mailing_list_id

  end
end
