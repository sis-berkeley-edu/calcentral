module User
  module FinancialAid
    class Queries < ::EdoOracle::Connection
      include ActiveRecordHelper
      include ClassLogger
      include Concerns::QueryHelper

      UC_BERKELEY = 'UCB01'

      def self.get_award_activity_dates(uid, aid_year:)
        query <<-SQL
          SELECT DISTINCT
          TO_CHAR(TO_DATE(SUBSTR(UC.ACTION_DTTM, 1,9),'DD-MON-YY'),'YYYY-MM-DD') AS activity_date
            FROM SYSADM.PS_UCC_FA_AWDCMPDT UC
           WHERE UC.CAMPUS_ID      = '#{uid}'
             AND UC.INSTITUTION    = '#{UC_BERKELEY}'
             AND UC.AID_YEAR       = '#{aid_year}'
             AND TO_CHAR(TO_DATE(SUBSTR(UC.ACTION_DTTM, 1,9),'DD-MON-YY'),'YYYY-MM-DD')
               <= (SELECT MAX(TO_CHAR(TO_DATE(SUBSTR(UC2.ACTION_DTTM, 1,9),'DD-MON-YY'),'YYYY-MM-DD'))
                     FROM SYSADM.PS_UCC_FA_AWDCMPDT UC2
                    WHERE UC2.CAMPUS_ID   = UC.CAMPUS_ID
                      AND UC2.INSTITUTION = UC.INSTITUTION
                      AND UC2.AID_YEAR    = UC.AID_YEAR)
          ORDER BY activity_date DESC
        SQL
      end

      def self.get_award_comparison_awards(uid, aid_year:, effective_date: Time.zone.today.in_time_zone.to_date)
        effective_date_string = effective_date.to_s

        query <<-SQL
          SELECT
            UC.DESCR AS description,
            UC.UC_AWARD_TYPE AS award_type,
            UC.OFFER_AMOUNT AS value
          FROM SYSADM.PS_UCC_FA_AWDCMPAW UC
          WHERE UC.CAMPUS_ID      = '#{uid}'
            AND UC.INSTITUTION    = '#{UC_BERKELEY}'
            AND UC.AID_YEAR       = '#{aid_year}'
            AND UC.ACTION_DTTM = (SELECT MAX(UC2.ACTION_DTTM) FROM SYSADM.PS_UCC_FA_AWDCMPAW UC2
                                WHERE UC2.EMPLID = UC.EMPLID
                                  AND UC2.INSTITUTION = UC.INSTITUTION
                                  AND UC2.AID_YEAR = UC.AID_YEAR
                                  AND UC2.ACTION_DTTM <= TO_TIMESTAMP('#{effective_date_string}23:59:59.99999','YYYY-MM-DDHH24:MI:SS.FF')
                                  AND UC2.ITEM_TYPE = UC.ITEM_TYPE)
            AND UC.OFFER_AMOUNT > 0
          ORDER BY UC.UC_AWARD_TYPE
        SQL
      end

      def self.get_award_comparison_cost(uid, aid_year:, effective_date: Time.zone.today.in_time_zone.to_date)
        effective_date_string = effective_date.to_s

        query <<-SQL
          SELECT
            UC.UC_SEQUENCE_1,
            UC.UC_SEQUENCE_2,
            UC.DESCR254_1 as description,
            SUM(UC.UC_BDGT_ITM_AMT_FA + UC.UC_BDGT_ITM_AMT_SP + UC.UC_BDGT_ITM_AMT_SU) as value
            FROM SYSADM.PS_UCC_FA_AWCMPBGT UC
           WHERE UC.CAMPUS_ID   = '#{uid}'
             AND UC.INSTITUTION = '#{UC_BERKELEY}'
             AND UC.AID_YEAR    = '#{aid_year}'
             AND UC.EFFDT       =  (SELECT MAX(UC2.EFFDT) FROM SYSADM.PS_UCC_FA_AWCMPBGT UC2
                                    WHERE UC2.EMPLID      = UC.EMPLID
                                      AND UC2.INSTITUTION = UC.INSTITUTION
                                      AND UC2.AID_YEAR    = UC.AID_YEAR
                                      AND UC2.STRM        = UC.STRM
                                      AND UC2.EFFDT      <= TO_DATE('#{effective_date_string}', 'YYYY-MM-DD'))
             AND UC.EFFSEQ      = (SELECT MAX(UC3.EFFSEQ) FROM SYSADM.PS_UCC_FA_AWCMPBGT UC3
                                    WHERE UC3.EMPLID      = UC.EMPLID
                                      AND UC3.INSTITUTION = UC.INSTITUTION
                                      AND UC3.AID_YEAR    = UC.AID_YEAR
                                      AND UC3.STRM        = UC.STRM
                                      AND UC3.EFFDT       = UC.EFFDT)
          GROUP BY UC.UC_SEQUENCE_1, UC.UC_SEQUENCE_2, UC.DESCR254_1
        SQL
      end

      def self.get_award_comparison_snapshot_data(uid, aid_year:, effective_date: Time.zone.today.in_time_zone.to_date)
        effective_date_string = effective_date.to_s

        query <<-SQL
          SELECT
            UC.DESCR             AS VERIFICATION_STATUS,
            UC.DESCR1            AS SAP_STATUS,
            UC.RATING_CMP_VALUE2 AS BERKELEY_PC
            FROM SYSADM.PS_UCC_FA_AWDCMPSN UC
           WHERE UC.CAMPUS_ID   = '#{uid}'
             AND UC.INSTITUTION = '#{UC_BERKELEY}'
             AND UC.AID_YEAR    = '#{aid_year}'
             AND UC.ACTION_DTTM =  (SELECT MAX(UC2.ACTION_DTTM) FROM SYSADM.PS_UCC_FA_AWDCMPSN UC2
                                    WHERE UC2.EMPLID      = UC.EMPLID
                                      AND UC2.INSTITUTION = UC.INSTITUTION
                                      AND UC2.AID_YEAR    = UC.AID_YEAR
                                      AND UC2.ACTION_DTTM <= TO_TIMESTAMP('#{effective_date_string} 23:59:59.999999', 'YYYY-MM-DD HH24:MI:SS.FF'))
        SQL
      end
    end
  end
end
