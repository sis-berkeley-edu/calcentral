module User
  module Notifications
    class Queries < ::EdoOracle::Connection
      include ActiveRecordHelper

      def self.notifications(uid)
        safe_query(notifications_query(uid))
      end

      def self.web_message_display(uid)
        safe_query(web_message_display_query(uid))
      end

      private

      def self.notifications_query(uid)
        <<-SQL
          SELECT
            cci_comm_trans_id as id,
            comm_dttm as status_datetime,
            descr as title,
            comm_category as category,
            scc_letter_cd as code,
            uc_respbl_descr as source,
            uc_comm_btn_descr as action_text,
            uc_fixed_url as source_url,
            admin_function,
            institution,
            aid_year
          FROM SYSADM.PS_UCC_CC_WEB_MSGV
          WHERE CAMPUS_ID = '#{uid}'
        SQL
      end

      def self.web_message_display_query(uid)
        <<-SQL
          SELECT
            due_dt as display_all_expires,
            uc_msg_display as should_display_all
          FROM SYSADM.PS_UCC_CC_WBMSG_DV
          WHERE CAMPUS_ID = '#{uid}'
        SQL
      end
    end
  end
end
