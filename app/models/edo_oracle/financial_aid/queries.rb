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
          UC_THIRD_PARTY,
          UC_NET_COST,
          UC_FUNDING_OFFERED,
          UC_GIFT_AID_OUT,
          UC_GRANTS_SCHOL,
          UC_OUTSIDE_RESRCES,
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

      def self.get_aid_years(person_id)
        safe_query <<-SQL
        SELECT UC.AID_YEAR,
          UC.AID_YEAR_DESCR,
          UC.DEFAULT_AID_YEAR,
          UC.AID_RECEIVED_FALL,
          UC.AID_RECEIVED_SPRING,
          UC.AID_RECEIVED_SUMMER
        FROM SISEDO.CLC_FA_AID_YEAR_V00_VW UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
        ORDER BY UC.AID_YEAR DESC
        SQL
      end

      def self.get_title4(person_id)
        result = safe_query <<-SQL
        SELECT UC.APPROVED,
          UC.RESPONSE_DESCR,
          UC.MAIN_HEADER,
          UC.MAIN_BODY,
          UC.DYNAMIC_HEADER,
          UC.DYNAMIC_BODY,
          UC.DYNAMIC_LABEL,
          UC.CONTACT_TEXT
        FROM SISEDO.CLC_FA_TITLE_IV_V00_VW UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
        SQL
        result.first
      end

      def self.get_terms_and_conditions(person_id, aid_year)
        result = safe_query <<-SQL
        SELECT UC.AID_YEAR,
          UC.APPROVED,
          UC.RESPONSE_DESCR,
          UC.MAIN_HEADER,
          UC.MAIN_BODY,
          UC.DYNAMIC_HEADER,
          UC.DYNAMIC_BODY
        FROM SISEDO.CLC_FA_T_C_V00_VW UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
          AND UC.AID_YEAR    = '#{aid_year}'
        ORDER BY UC.AID_YEAR
        SQL
        result.first
      end

      def self.get_finaid_profile_status(person_id, aid_year, effective_date: Time.zone.today.in_time_zone.to_date)
        effective_date_string = effective_date.to_s

        result = safe_query <<-SQL
        SELECT
          UC.AID_YEAR             AS AID_YEAR,
          UC.DESCR                AS ACAD_CAREER_DESCR,
          UC.DESCR2               AS EXP_GRAD_TERM,
          UC.DESCR3               AS SAP_STATUS,
          UC.DESCR4               AS VERIFICATION_STATUS,
          UC.DESCR5               AS AWARD_STATUS,
          UC.DESCRFORMAL          AS CANDIDACY,
          UC.DESCR7               AS FILING_FEE,
          UC.DESCR8               AS BERKELEY_PC,
          UC.TITLE                AS TITLE,
          UC.MESSAGE_TEXT_LONG    AS MESSAGE
         FROM SYSADM.PS_UCC_FA_PRFL_FAT UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
          AND UC.AID_YEAR    = '#{aid_year}'
          AND UC.EFFDT  = (SELECT MAX(UC2.EFFDT) FROM SYSADM.PS_UCC_FA_PRFL_FAT UC2
                           WHERE UC2.EMPLID      = UC.EMPLID
                             AND UC2.INSTITUTION = UC.INSTITUTION
                             AND UC2.AID_YEAR    = UC.AID_YEAR
                             AND UC2.EFFDT      <= TO_DATE('#{effective_date_string}', 'YYYY-MM-DD'))
          AND UC.EFFSEQ = (SELECT MAX(UC3.EFFSEQ) FROM SYSADM.PS_UCC_FA_PRFL_FAT UC3
                           WHERE UC3.EMPLID      = UC.EMPLID
                             AND UC3.INSTITUTION = UC.INSTITUTION
                             AND UC3.AID_YEAR    = UC.AID_YEAR
                             AND UC3.STRM        = UC.STRM
                             AND UC3.EFFDT       = UC.EFFDT)
          AND UC.EFF_STATUS = 'A'
          AND (((UC.STRM NOT LIKE '%5') AND (UC.TERM_SRC <> 'N'))
          OR ((UC.STRM LIKE '%5') AND (UC.TERM_SRC = 'T')))
        ORDER BY UC.AID_YEAR
        SQL
        result.first
      end

      def self.get_finaid_profile_acad_careers(person_id, aid_year, effective_date: Time.zone.today.in_time_zone.to_date)
        effective_date_string = effective_date.to_s

        safe_query <<-SQL
        SELECT
          UC.AID_YEAR             AS AID_YEAR,
          UC.STRM                 AS TERM_ID,
          UC.DESCR                AS TERM_DESCR,
          UC.DESCR2               AS ACAD_CAREER
         FROM SYSADM.PS_UCC_FA_PRFL_CAR UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
          AND UC.AID_YEAR    = '#{aid_year}'
          AND UC.EFFDT = (SELECT MAX(UC2.EFFDT) FROM SYSADM.PS_UCC_FA_PRFL_CAR UC2
                          WHERE UC2.EMPLID      = UC.EMPLID
                            AND UC2.INSTITUTION = UC.INSTITUTION
                            AND UC2.AID_YEAR    = UC.AID_YEAR
                            AND UC2.STRM        = UC.STRM
                            AND UC2.EFFDT      <= TO_DATE('#{effective_date_string}', 'YYYY-MM-DD'))
          AND UC.EFFSEQ = (SELECT MAX(UC3.EFFSEQ) FROM SYSADM.PS_UCC_FA_PRFL_CAR UC3
                          WHERE UC3.EMPLID      = UC.EMPLID
                            AND UC3.INSTITUTION = UC.INSTITUTION
                            AND UC3.AID_YEAR    = UC.AID_YEAR
                            AND UC3.STRM        = UC.STRM
                            AND UC3.EFFDT       = UC.EFFDT)
          AND UC.EFF_STATUS = 'A'
          AND (((UC.STRM NOT LIKE '%5') AND (UC.TERM_SRC <> 'N'))
           OR ((UC.STRM LIKE '%5') AND (UC.TERM_SRC = 'T')))
          ORDER BY UC.AID_YEAR, UC.STRM
        SQL
      end

      def self.get_finaid_profile_acad_level(person_id, aid_year, effective_date: Time.zone.today.in_time_zone.to_date)
        effective_date_string = effective_date.to_s

        safe_query <<-SQL
        SELECT
          UC.AID_YEAR             AS AID_YEAR,
          UC.STRM                 AS TERM_ID,
          UC.DESCR                AS TERM_DESCR,
          UC.DESCR2               AS ACAD_LEVEL
         FROM SYSADM.PS_UCC_FA_PRFL_LVL UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
          AND UC.AID_YEAR    = '#{aid_year}'
          AND UC.EFFDT = (SELECT MAX(UC2.EFFDT) FROM SYSADM.PS_UCC_FA_PRFL_LVL UC2
                          WHERE UC2.EMPLID      = UC.EMPLID
                            AND UC2.INSTITUTION = UC.INSTITUTION
                            AND UC2.AID_YEAR    = UC.AID_YEAR
                            AND UC2.STRM        = UC.STRM
                            AND UC2.EFFDT      <= TO_DATE('#{effective_date_string}', 'YYYY-MM-DD'))
          AND UC.EFFSEQ = (SELECT MAX(UC3.EFFSEQ) FROM SYSADM.PS_UCC_FA_PRFL_LVL UC3
                          WHERE UC3.EMPLID      = UC.EMPLID
                            AND UC3.INSTITUTION = UC.INSTITUTION
                            AND UC3.AID_YEAR    = UC.AID_YEAR
                            AND UC3.STRM        = UC.STRM
                            AND UC3.EFFDT       = UC.EFFDT)
          AND UC.EFF_STATUS = 'A'
          AND (((UC.STRM NOT LIKE '%5') AND (UC.TERM_SRC <> 'N'))
           OR ((UC.STRM LIKE '%5') AND (UC.TERM_SRC = 'T')))
        ORDER BY UC.AID_YEAR, UC.STRM
        SQL
      end

      def self.get_finaid_profile_enrollment(person_id, aid_year, effective_date: Time.zone.today.in_time_zone.to_date)
        effective_date_string = effective_date.to_s

        safe_query <<-SQL
        SELECT
          UC.AID_YEAR                         AS AID_YEAR,
          UC.STRM                             AS TERM_ID,
          UC.DESCR                            AS TERM_DESCR,
          UC.DESCR2                           AS TERM_UNITS
         FROM SYSADM.PS_UCC_FA_PRFL_ENR UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
          AND UC.AID_YEAR    = '#{aid_year}'
          AND UC.EFFDT       = (SELECT MAX(UC2.EFFDT) FROM SYSADM.PS_UCC_FA_PRFL_ENR UC2
                                WHERE UC2.EMPLID      = UC.EMPLID
                                  AND UC2.INSTITUTION = UC.INSTITUTION
                                  AND UC2.AID_YEAR    = UC.AID_YEAR
                                  AND UC2.STRM        = UC.STRM
                                  AND UC2.EFFDT      <= TO_DATE('#{effective_date_string}', 'YYYY-MM-DD'))
          AND UC.EFFSEQ      = (SELECT MAX(UC3.EFFSEQ) FROM SYSADM.PS_UCC_FA_PRFL_ENR UC3
                                WHERE UC3.EMPLID      = UC.EMPLID
                                  AND UC3.INSTITUTION = UC.INSTITUTION
                                  AND UC3.AID_YEAR    = UC.AID_YEAR
                                  AND UC3.STRM        = UC.STRM
                                  AND UC3.EFFDT       = UC.EFFDT)
          AND UC.EFF_STATUS = 'A'
          AND UC.TERM_SRC IN ('T','M')
        ORDER BY UC.AID_YEAR, UC.STRM
        SQL
      end

      def self.get_finaid_profile_SHIP(person_id, aid_year, effective_date: Time.zone.today.in_time_zone.to_date)
        effective_date_string = effective_date.to_s

        safe_query <<-SQL
        SELECT
          UC.AID_YEAR                         AS AID_YEAR,
          UC.STRM                             AS TERM_ID,
          UC.DESCR                            AS TERM_DESCR,
          UC.DESCR2                           AS SHIP_STATUS
         FROM SYSADM.PS_UCC_FA_PRFL_SHP UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
          AND UC.AID_YEAR    = '#{aid_year}'
          AND UC.EFFDT       = (SELECT MAX(UC2.EFFDT) FROM SYSADM.PS_UCC_FA_PRFL_SHP UC2
                                WHERE UC2.EMPLID      = UC.EMPLID
                                  AND UC2.INSTITUTION = UC.INSTITUTION
                                  AND UC2.AID_YEAR    = UC.AID_YEAR
                                  AND UC2.STRM        = UC.STRM
                                  AND UC2.EFFDT      <= TO_DATE('#{effective_date_string}', 'YYYY-MM-DD'))
          AND UC.EFFSEQ      = (SELECT MAX(UC3.EFFSEQ) FROM SYSADM.PS_UCC_FA_PRFL_SHP UC3
                                WHERE UC3.EMPLID      = UC.EMPLID
                                  AND UC3.INSTITUTION = UC.INSTITUTION
                                  AND UC3.AID_YEAR    = UC.AID_YEAR
                                  AND UC3.STRM        = UC.STRM
                                  AND UC3.EFFDT       = UC.EFFDT)
          AND UC.EFF_STATUS = 'A'
          AND (((UC.STRM NOT LIKE '%5') AND (UC.TERM_SRC <> 'N'))
           OR ((UC.STRM LIKE '%5') AND (UC.TERM_SRC = 'T')))
        ORDER BY UC.AID_YEAR, UC.STRM
        SQL
      end

      def self.get_finaid_profile_residency(person_id, aid_year, effective_date: Time.zone.today.in_time_zone.to_date)
        effective_date_string = effective_date.to_s

        safe_query <<-SQL
        SELECT
          UC.AID_YEAR             AS AID_YEAR,
          UC.STRM                 AS TERM_ID,
          UC.DESCR                AS TERM_DESCR,
          UC.DESCR100             AS RESIDENCY
         FROM SYSADM.PS_UCC_FA_PRFL_RES UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
          AND UC.AID_YEAR    = '#{aid_year}'
          AND UC.EFFDT       = (SELECT MAX(UC2.EFFDT) FROM SYSADM.PS_UCC_FA_PRFL_RES UC2
                                WHERE UC2.EMPLID      = UC.EMPLID
                                  AND UC2.INSTITUTION = UC.INSTITUTION
                                  AND UC2.AID_YEAR    = UC.AID_YEAR
                                  AND UC2.STRM        = UC.STRM
                                  AND UC2.EFFDT      <= TO_DATE('#{effective_date_string}', 'YYYY-MM-DD'))
          AND UC.EFFSEQ      = (SELECT MAX(UC3.EFFSEQ) FROM SYSADM.PS_UCC_FA_PRFL_RES UC3
                                WHERE UC3.EMPLID      = UC.EMPLID
                                  AND UC3.INSTITUTION = UC.INSTITUTION
                                  AND UC3.AID_YEAR    = UC.AID_YEAR
                                  AND UC3.STRM        = UC.STRM
                                  AND UC3.EFFDT       = UC.EFFDT)
          AND UC.EFF_STATUS = 'A'
          AND (((UC.STRM NOT LIKE '%5') AND (UC.TERM_SRC <> 'N'))
           OR ((UC.STRM LIKE '%5') AND (UC.TERM_SRC = 'T')))
          AND UC.DESCR100 IS NOT NULL
        ORDER BY UC.AID_YEAR, UC.STRM
        SQL
      end

      def self.get_finaid_profile_isir(person_id, aid_year, effective_date: Time.zone.today.in_time_zone.to_date)
        effective_date_string = effective_date.to_s

        result = safe_query <<-SQL
        SELECT
          UC.AID_YEAR             AS AID_YEAR,
          UC.DESCR                AS DEPENDENCY_STATUS,
          UC.DESCR2               AS PRIMARY_EFC,
          UC.DESCR3               AS SUMMER_EFC,
          UC.DESCR4               AS FAMILY_IN_COLLEGE
         FROM SYSADM.PS_UCC_FA_PRFL_ISR UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
          AND UC.AID_YEAR    = '#{aid_year}'
          AND UC.EFFDT       = (SELECT MAX(UC2.EFFDT) FROM SYSADM.PS_UCC_FA_PRFL_ISR UC2
                                WHERE UC2.EMPLID      = UC.EMPLID
                                  AND UC2.INSTITUTION = UC.INSTITUTION
                                  AND UC2.AID_YEAR    = UC.AID_YEAR
                                  AND UC2.EFFDT      <= TO_DATE('#{effective_date_string}', 'YYYY-MM-DD'))
          AND UC.EFFSEQ      = (SELECT MAX(UC3.EFFSEQ) FROM SYSADM.PS_UCC_FA_PRFL_ISR UC3
                                WHERE UC3.EMPLID      = UC.EMPLID
                                  AND UC3.INSTITUTION = UC.INSTITUTION
                                  AND UC3.AID_YEAR    = UC.AID_YEAR
                                  AND UC3.EFFDT       = UC.EFFDT)
        ORDER BY UC.AID_YEAR
        SQL
        result.first
      end

      def self.get_awards(person_id, aid_year)
        safe_query <<-SQL
        SELECT UC.ITEM_TYPE       AS ITEM_TYPE,
          UC.DESCR                AS TITLE,
          UC.DESCRLONG            AS SUBTITLE,
          UC.UC_AWARD_TYPE        AS AWARD_TYPE,
          UC.UC_LEFT_COL_VAL      AS LEFT_COL_VAL,
          UC.UC_AWARD_AMOUNT      AS LEFT_COL_AMT,
          UC.UC_RIGHT_COL_VAL     AS RIGHT_COL_VAL,
          UC.UC_DISBURSE_AMOUNT   AS RIGHT_COL_AMT,
          TRIM(UC.UC_DESCRLONG)   AS AWARD_MESSAGE
          FROM SYSADM.PS_UCC_FA_AWRD_SRC UC
         WHERE UC.CAMPUS_ID   = '#{person_id}'
           AND UC.INSTITUTION = '#{UC_BERKELEY}'
           AND UC.AID_YEAR    = '#{aid_year}'
         ORDER BY UC.UC_AWARD_TYPE, UC.ITEM_TYPE
        SQL
      end

      def self.get_awards_by_type(person_id, aid_year, award_type)
        safe_query <<-SQL
        SELECT UC.ITEM_TYPE       AS ITEM_TYPE,
          UC.DESCR                AS TITLE,
          UC.DESCRLONG            AS SUBTITLE,
          UC.UC_AWARD_TYPE        AS AWARD_TYPE,
          UC.UC_LEFT_COL_VAL      AS LEFT_COL_VAL,
          UC.UC_AWARD_AMOUNT      AS LEFT_COL_AMT,
          UC.UC_RIGHT_COL_VAL     AS RIGHT_COL_VAL,
          UC.UC_DISBURSE_AMOUNT   AS RIGHT_COL_AMT,
          UC.UC_DESCRLONG         AS AWARD_MESSAGE
          FROM SYSADM.PS_UCC_FA_AWRD_SRC UC
         WHERE UC.CAMPUS_ID   = '#{person_id}'
           AND UC.INSTITUTION = '#{UC_BERKELEY}'
           AND UC.AID_YEAR    = '#{aid_year}'
           AND UC.UC_AWARD_TYPE = '#{award_type}'
        SQL
      end

      def self.get_awards_total_by_type(person_id, aid_year, award_type)
        safe_query <<-SQL
        SELECT SUM(UC.UC_AWARD_AMOUNT)  AS TOTAL
          FROM SYSADM.PS_UCC_FA_AWRD_SRC UC
         WHERE UC.CAMPUS_ID   = '#{person_id}'
           AND UC.INSTITUTION = '#{UC_BERKELEY}'
           AND UC.AID_YEAR    = '#{aid_year}'
           AND UC.UC_AWARD_TYPE = '#{award_type}'
        SQL
      end

      def self.get_awards_total(person_id, aid_year)
        safe_query <<-SQL
        SELECT SUM(UC.UC_AWARD_AMOUNT)  AS TOTAL
          FROM SYSADM.PS_UCC_FA_AWRD_SRC UC
         WHERE UC.CAMPUS_ID   = '#{person_id}'
           AND UC.INSTITUTION = '#{UC_BERKELEY}'
           AND UC.AID_YEAR    = '#{aid_year}'
        SQL
      end

      def self.get_awards_disbursements(person_id, aid_year, item_type)
        safe_query <<-SQL
        SELECT DISTINCT UC.DISBURSEMENT_ID AS DISBURSEMENTID,
          UC.DESCR                AS TERM,
          UC.OFFER_BALANCE        AS OFFERED,
          UC.DISBURSED_BALANCE    AS DISBURSED,
          UC.DESCR1               AS DISBURSEMENT_DATE
          FROM SYSADM.PS_UCC_FA_AWRD_DSB UC
         WHERE UC.CAMPUS_ID   = '#{person_id}'
           AND UC.INSTITUTION = '#{UC_BERKELEY}'
           AND UC.AID_YEAR    = '#{aid_year}'
           AND UC.ITEM_TYPE   = '#{item_type}'
        SQL
      end

      def self.get_awards_disbursements_tuition_fee_remission(person_id, aid_year)
        safe_query <<-SQL
        SELECT DISTINCT UC.DISBURSEMENT_ID AS DISBURSEMENTID,
          UC.DESCR                  AS TERM,
          SUM(UC.OFFER_BALANCE)     AS OFFERED,
          SUM(UC.DISBURSED_BALANCE) AS DISBURSED,
          NULL                      AS DISBURSEMENT_DATE
          FROM SYSADM.PS_UCC_FA_AWRD_DSB UC
         WHERE UC.CAMPUS_ID   = '#{person_id}'
           AND UC.INSTITUTION = '#{UC_BERKELEY}'
           AND UC.AID_YEAR    = '#{aid_year}'
           AND UC.ITEM_TYPE BETWEEN '992000000010' AND '995999999999'
         GROUP BY UC.DISBURSEMENT_ID, UC.DESCR
        SQL
      end

      def self.get_awards_alert_details(person_id, aid_year, item_type)
        safe_query <<-SQL
          SELECT UC.DISBURSEMENT_ID AS DISBURSEMENTID,
            TO_CHAR(UC.DESCRLONG)   AS ALERT_MESSAGE,
            UC.DESCR                AS ALERT_TERM
            FROM SYSADM.PS_UCC_FA_AWRD_DSB UC
           WHERE UC.CAMPUS_ID   = '#{person_id}'
             AND UC.INSTITUTION = '#{UC_BERKELEY}'
             AND UC.AID_YEAR    = '#{aid_year}'
             AND UC.ITEM_TYPE   = '#{item_type}'
             AND UC.DESCRLONG IS NOT NULL
           ORDER BY UC.DISBURSEMENT_ID
        SQL
      end

      def self.get_awards_convert_wks_to_loan(person_id, aid_year)
        result = safe_query <<-SQL
        SELECT 'X'
          FROM SYSADM.PS_UCC_FA_AWRD_W2L UC
         WHERE UC.CAMPUS_ID   = '#{person_id}'
           AND UC.INSTITUTION = '#{UC_BERKELEY}'
           AND UC.AID_YEAR    = '#{aid_year}'
        SQL
        result.first
      end

      def self.get_awards_convert_loan_to_wks(person_id, aid_year)
        result = safe_query <<-SQL
        SELECT 'X'
          FROM SYSADM.PS_UCC_FA_AWRD_L2W UC
         WHERE UC.CAMPUS_ID   = '#{person_id}'
           AND UC.INSTITUTION = '#{UC_BERKELEY}'
           AND UC.AID_YEAR    = '#{aid_year}'
        SQL
        result.first
      end

      def self.get_awards_outside_resources(aid_year)
        result = safe_query <<-SQL
        SELECT 'X'
          FROM SYSADM.PS_UCC_FA_AWRD_OUT UC
          WHERE UC.INSTITUTION = '#{UC_BERKELEY}'
            AND UC.AID_YEAR    = '#{aid_year}'
        SQL
        result.first
      end

      def self.get_awards_reduce_cancel(person_id, aid_year)
        result = safe_query <<-SQL
        SELECT 'X'
          FROM SYSADM.PS_UCC_FA_AWRD_RDC UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
          AND UC.AID_YEAR    = '#{aid_year}'
        SQL
        result.first
      end

      def self.get_awards_accept_loans(person_id, aid_year, item_type)
        result = safe_query <<-SQL
        SELECT 'X'
          FROM SYSADM.PS_UCC_FA_AWRD_LNS UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
          AND UC.AID_YEAR    = '#{aid_year}'
          AND UC.ITEM_TYPE   = '#{item_type}'
        SQL
        result.first
      end

      def self.get_auth_failed_message(person_id, aid_year, item_type)
        result = safe_query <<-SQL
        SELECT 'X'
          FROM SYSADM.PS_UCC_FA_AWRD_ATH UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
          AND UC.AID_YEAR    = '#{aid_year}'
          AND UC.ITEM_TYPE   = '#{item_type}'
        SQL
        result.first
      end

      def self.get_awards_has_loans(person_id, aid_year)
        result = safe_query <<-SQL
        SELECT 'X'
          FROM SYSADM.PS_UCC_FA_AWRD_SRC UC
        WHERE UC.CAMPUS_ID   = '#{person_id}'
          AND UC.INSTITUTION = '#{UC_BERKELEY}'
          AND UC.AID_YEAR    = '#{aid_year}'
          AND UC.UC_AWARD_TYPE IN ('subsidizedloans', 'unsubsidizedloans', 'plusloans', 'alternativeloans')
        SQL
        result.first
      end

      def self.get_awards_by_term_types(person_id, aid_year)
        safe_query <<-SQL
        SELECT DISTINCT UC.UC_AWARD_TYPE AS AWARD_TYPE,
          CASE
            WHEN UC.UC_AWARD_TYPE = 'giftaid'           THEN 'Gift Aid'
            WHEN UC.UC_AWARD_TYPE = 'waiversAndOther'   THEN 'Waivers and Other Funding'
            WHEN UC.UC_AWARD_TYPE = 'workstudy'         THEN 'Work-Study'
            WHEN UC.UC_AWARD_TYPE = 'subsidizedloans'   THEN 'Subsidized Loans'
            WHEN UC.UC_AWARD_TYPE = 'unsubsidizedloans' THEN 'Unsubsidized Loans'
            WHEN UC.UC_AWARD_TYPE = 'plusloans'         THEN 'PLUS Loans'
            WHEN UC.UC_AWARD_TYPE = 'alternativeloans'  THEN 'Alternative Loans'
            ELSE null
          END AS AWARD_TYPE_DESCR
          FROM SYSADM.PS_UCC_FA_AWRD_TRM UC
        WHERE UC.CAMPUS_ID          = '#{person_id}'
          AND UC.INSTITUTION        = '#{UC_BERKELEY}'
          AND UC.AID_YEAR           = '#{aid_year}'
        ORDER BY (CASE UC.UC_AWARD_TYPE
          WHEN 'giftaid'            THEN 10
          WHEN 'waiversAndOther'    THEN 20
          WHEN 'workstudy'          THEN 30
          WHEN 'subsidizedloans'    THEN 40
          WHEN 'unsubsidizedloans'  THEN 50
          WHEN 'plusloans'          THEN 60
          WHEN 'alternativeloans'   THEN 70
          ELSE 80 END) ASC
        SQL
      end

      def self.get_awards_by_term_by_type(person_id, aid_year, award_type)
        safe_query <<-SQL
        SELECT UC.ITEM_TYPE         AS ITEM_TYPE,
          UC.DESCR                  AS TITLE,
          UC.UC_AWARD_TYPE          AS AWARD_TYPE,
          UC.UC_AWARD_AMT_FAL       AS AMOUNT_FALL,
          UC.UC_AWARD_AMT_SPR       AS AMOUNT_SPRING,
          UC.UC_AWARD_AMT_SUM       AS AMOUNT_SUMMER
          FROM SYSADM.PS_UCC_FA_AWRD_TRM UC
        WHERE UC.CAMPUS_ID          = '#{person_id}'
          AND UC.INSTITUTION        = '#{UC_BERKELEY}'
          AND UC.AID_YEAR           = '#{aid_year}'
          AND UC.UC_AWARD_TYPE         = '#{award_type}'
        ORDER BY  UC.ITEM_TYPE ASC
        SQL
      end

      def self.get_financial_resources_links
        safe_query <<-SQL
         SELECT UC.URL_ID          AS URL_ID
           FROM SYSADM.PS_UCC_LINKAPIURL UC
          WHERE UC.URL_ID LIKE 'UC_FA_FINRES%'
        SQL
      end
    end
  end
end
