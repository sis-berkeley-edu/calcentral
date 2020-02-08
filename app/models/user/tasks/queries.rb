module User
  module Tasks
    class Queries < ::EdoOracle::Connection
      include ActiveRecordHelper

      def self.completed_agreements(uid)
        safe_query(completed_agreements_query(uid))
      end

      def self.incomplete_agreements(uid)
        safe_query(incomplete_agreements_query(uid))
      end

      def self.completed_checklist_items(uid)
        safe_query(completed_checklist_items_query(uid))
      end

      def self.incomplete_checklist_items(uid)
        safe_query(incomplete_checklist_items_query(uid))
      end

      def self.notifications(uid)
        safe_query(notifications_query(uid))
      end

      def self.web_message_display(uid)
        safe_query(web_message_display_query(uid))
      end

      private

      def self.completed_agreements_query(uid)
        <<-SQL
          SELECT
            admin_function,
            cci_comm_deny_chng as updates_forbidden,
            cci_comm_disable as disable_updates_after_expiration,
            cci_comm_display as visible_after_expiration,
            cci_comm_trans_id as transaction_id,
            datetime_created as response_date,
            descr as title,
            expire_dt as expiration_date,
            uc_response_descr as response,
            aid_year
          FROM SYSADM.PS_UCC_CC_CMPAGMTV
          WHERE CAMPUS_ID = '#{uid}'
        SQL
      end

      def self.incomplete_agreements_query(uid)
        <<-SQL
          SELECT
            admin_function,
            aid_year,
            aid_year_descr as aid_year_description,
            cci_comm_trans_id as transaction_id,
            comm_dttm as assigned_date,
            descr as title,
            descr250 as description,
            expire_dt as expires_on,
            uc_respbl_descr as department_name
          FROM SYSADM.PS_UCC_CC_ACTAGMTV
          WHERE CAMPUS_ID = '#{uid}'
        SQL
      end

      def self.completed_checklist_items_query(uid)
        <<-SQL
          SELECT
            checklist_cd as checklist_code,
            seq_3c as sequence_number,
            checklist_seq as checklist_sequence,
            chklst_item_cd as item_code,
            admin_function,
            item_status as status_code,
            status_dt as status_date,
            descr as title,
            descrlong as description,
            due_dt as due_date,
            ext_org_name as organization_name,
            uc_resp_dept_name as department_name,
            uc_resp_email as responsible_email,
            aid_year as aid_year,
            aid_year_descr as aid_year_description,
            uc_item_status_xlt as item_status_xlt
          FROM SYSADM.PS_UCC_CC_CMPCHKIV
          WHERE CAMPUS_ID = '#{uid}'
        SQL
      end

      def self.incomplete_checklist_items_query(uid)
        <<-SQL
          SELECT
            admin_function,
            uc_display_text as action_text,
            url as action_url,
            aid_year,
            aid_year_descr as aid_year_description,
            status_dt as status_date,
            uc_resp_dept_name as department_name,
            descrlong as description,
            due_dt as due_date,
            ext_org_name as organization_name,
            chklst_item_cd as item_code,
            item_status as status_code,
            descr as title,
            uc_upload_flag as has_upload_button,
            url_id as upload_url_id,
            seq_3c as sequence_id,
            checklist_seq as checklist_id,
            chklst_item_cd as checklist_item_code,
            uc_strm_career as term_career_code,
            strm as term_id,
            uc_adma_career as career,
            adm_appl_nbr as admissions_application_number,
            stdnt_car_nbr as career_number
          FROM SYSADM.PS_UCC_CC_CHKLITMV
          WHERE CAMPUS_ID = '#{uid}'
        SQL
      end

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
            due_dt as cutoff_time,
            uc_msg_display as should_display
          FROM SYSADM.PS_UCC_CC_WBMSG_DV
          WHERE CAMPUS_ID = '#{uid}'
        SQL
      end
    end
  end
end
