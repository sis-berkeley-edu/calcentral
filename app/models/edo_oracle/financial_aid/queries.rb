module EdoOracle
  module FinancialAid
    class Queries < Connection
      include ActiveRecordHelper
      include ClassLogger
      include Concerns::QueryHelper

      def self.get_housing(person_id, aid_year)
        safe_query <<-SQL
        SELECT DISTINCT
          HSG.TERM_ID,
          HSG.TERM_DESCR,
          HSG.HOUSING_OPTION,
          HSG.HOUSING_STATUS,
          HSG.HOUSING_END_DATE,
          HSG.ACAD_CAREER
        FROM SISEDO.CLC_FA_HOUSING_VW HSG
        WHERE HSG.CAMPUS_UID = '#{person_id}'
        AND HSG.AID_YEAR = '#{aid_year}'
        ORDER BY HSG.TERM_ID
        SQL
      end
      def self.get_loan_history_status (student_id)
        result = safe_query <<-SQL
        SELECT
          IS_STUDENT_ACTIVE as active
        FROM
          SISEDO.CLC_FA_LNHST_IS_ACTIVE_VW
        WHERE
          STUDENT_ID = '#{student_id}'
        SQL
        result.first
      end

      def self.enrolled_pre_fall_2016 (student_id)
        result = safe_query <<-SQL
        SELECT
          VW.ENRL_PRE_2168 as enrolled
        FROM
          SISEDO.CLC_FA_LNHST_STD_ENRL_PRE_2168 VW
        WHERE
          STUDENT_ID = '#{student_id}'
          #{and_institution('VW')}
        SQL
        result.first
      end

      def self.get_loan_history_categories_cumulative
        safe_query <<-SQL
        SELECT
          SEQ_NUM as parent_sequence,
          CATEGORY_TITLE as category_title,
          CATEGORY_TEXT as category_descr,
          CATEGORY_TEXT_PRE_2168 as category_descr_pre_2168,
          SEQ_NUM_TYPE as child_sequence,
          TYPE_TITLE as loan_type,
          TYPE_MIN_AMOUNT as min_loan_amt,
          TYPE_DURATION as loan_duration,
          TYPE_INTEREST_RATE as loan_interest_rate,
          TYPE_DETAILS_VIEW_NAME as loan_child_vw
        FROM
          SISEDO.CLC_FA_LNHST_CUMULATIVE
        WHERE
          INSTITUTION = '#{UC_BERKELEY}'
        SQL
      end

      def self.get_loan_history_cumulative_loan_amount (student_id, view_name)
        result = safe_query <<-SQL
        SELECT
          LOAN_AMOUNT as amount
        FROM
          SISEDO.#{view_name}
        WHERE
          STUDENT_ID = '#{student_id}'
        SQL
        result.first
      end

      def self.get_loan_history_categories_aid_years(student_id)
        safe_query <<-SQL
        SELECT
          AID_YEAR as aid_year,
          SEQ_NUM as sequence,
          TYPE_DESCRIPTION as loan_type,
          TYPE_MIN_AMOUNT as min_loan_amt,
          TYPE_DURATION as loan_duration,
          TYPE_INTEREST_RATE as loan_interest_rate,
          USE_NSLDS_INTEREST_RATE as use_nslds_interest_rate,
          TYPE_DETAILS_VIEW_NAME as loan_child_vw
        FROM
          SISEDO.CLC_FA_LNHST_CATEGORIES_AID_YEAR CAT
        WHERE
          STUDENT_ID = '#{student_id}'
          #{and_institution('CAT')}
        SQL
      end

      def self.get_loan_history_aid_years_details(student_id, view_name)
        safe_query <<-SQL
        SELECT
          AID_YEAR as aid_year,
          FA_SOURCE_DESCR as loan_category,
          LOAN_DESCR as loan_descr,
          LOAN_AMOUNT as loan_amount,
          LOAN_INTEREST_RATE as interest_rate
        FROM
          SISEDO.#{view_name} A
        WHERE
          STUDENT_ID = '#{student_id}' 
          #{and_institution('A')}
        SQL
      end

      def self.get_loan_history_resources
        safe_query <<-SQL
        SELECT
          SEQ_NUM as sequence,
          RESOURCE_URL as url,
          RESOURCE_TITLE as title,
          RESOURCE_TEXT as descr,
          RESOURCE_HOVER_OVER as hover
        FROM
          SISEDO.CLC_FA_LNHST_RESOURCES
        WHERE
          INSTITUTION = '#{UC_BERKELEY}'
        SQL
      end

      def self.get_loan_history_glossary_cumulative
        safe_query <<-SQL
        SELECT
          SEQ_NUM as sequence,
          GLOSSARY_ITEM_CD as code,
          GLOSSARY_TITLE as term,
          GLOSSARY_TEXT as definition
        FROM
          SISEDO.CLC_FA_LNHST_GLOSSARY_CUMULATIVE
        WHERE
          INSTITUTION = '#{UC_BERKELEY}'
        SQL
      end

      def self.get_loan_history_glossary_aid_years
        safe_query <<-SQL
        SELECT
          SEQ_NUM as sequence,
          GLOSSARY_ITEM_CD as code,
          GLOSSARY_TITLE as term,
          GLOSSARY_TEXT as definition
        FROM
          SISEDO.CLC_FA_LNHST_GLOSSARY_AID_YEAR
        WHERE
          INSTITUTION = '#{UC_BERKELEY}'
        SQL
      end

      def self.get_loan_history_messages (message_codes=[])
        message_codes_sql = message_codes.join("\',\'")
        safe_query <<-SQL
        SELECT
          MESSAGE_TYPE_CD as code,
          MESSAGE_TITLE as title,
          MESSAGE_TEXT as description
        FROM
          SISEDO.CLC_FA_LNHST_MESSAGES MSG
        WHERE
          MESSAGE_TYPE_CD IN ('#{message_codes_sql}')
          #{and_institution('MSG')}
        SQL
      end

      def self.get_financial_aid_summary(person_id, aid_year)
        result = safe_query <<-SQL
        SELECT STUDENT_ID,
          UC_COST_ATTENDANCE,
          UC_GIFT_AID_WAIVER,
          UC_NET_COST,
          UC_FUNDING_OFFERED,
          UC_GIFT_AID_OUT,
          UC_GRANTS_SCHOL,
          UC_WAIVERS_OTH,
          UC_FEE_WAIVERS,
          UC_LOANS_WRK_STUDY,
          UC_LOANS,
          UC_WORK_STUDY,
          SFA_SS_GROUP
        FROM SISEDO.CLC_FA_FASO_V00_VW
        WHERE CAMPUS_UID = '#{person_id}'
        AND AID_YEAR = '#{aid_year}'
        SQL
        result.first
      end
    end
  end
end

