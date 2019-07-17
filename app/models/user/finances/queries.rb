module User
  module Finances
    class Queries < ::EdoOracle::Connection
      include ActiveRecordHelper
      include ClassLogger
      include Concerns::QueryHelper

      def self.transactions_for(uid)
        query <<-SQL
          SELECT
            ACCOUNT_TERM as term_id,
            ITEM_AMT as amount,
            ITEM_BALANCE as balance,
            DUE_AMT as amount_due,
            REF1_DESCR as transaction_number,
            PAYMENT_ID_NBR as payment_id,
            ITEM_TERM as term_id,
            ITEM_TYPE_CD as type_code,
            DUE_DT as due_date,
            ORIGNL_ITEM_AMT as original_item_amount,
            ITEM_EFFECTIVE_DT as updated_on,
            BUSINESS_UNIT as business_unit,
            COMMON_ID as common_id,
            ITEM_NBR as item_id,
            LINE_SEQ_NBR as sequence_id,
            LINE_AMT as sequence_amount,
            POSTED_DATE as sequence_posted,
            DESCR as description
          FROM SYSADM.PS_UCC_SF_BILLLINE
          WHERE CAMPUS_ID = '#{uid}'
          ORDER BY sequence_posted DESC
        SQL
      end

      def self.uid_payments_by_item_number(uid, item_number)
        query <<-SQL
          SELECT 
            DESCR2 as description,
            XREF_AMT as amount_paid,
            POSTED_DATE,
            EFFDT as effective_date
          FROM SYSADM.PS_UCC_SF_BILLPYMT
          WHERE CAMPUS_ID = '#{uid}' AND ITEM_NBR='#{item_number}'
        SQL
      end
    end
  end
end
