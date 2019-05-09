module MyAcademics
  module Law
    class Queries < ::EdoOracle::Connection
      include ActiveRecordHelper
      include ClassLogger
      include Concerns::QueryHelper

      def self.awards_for_user(uid)
        safe_query <<-SQL
          SELECT
            DT_RECVD    as received_on,
            AWARD_CODE  as award_code,
            DESCRFORMAL as description
          FROM SYSADM.PS_UCC_SR_LAW_AWDS
          WHERE CAMPUS_ID = '#{uid}'
        SQL
      end

      def self.notes_for_user(uid)
        safe_query <<-SQL
          SELECT
            STRM           as term_id,
            TSCRPT_NOTE_ID as note_id,
            DESCRSHORT     as term_name,
            DESCR          as class_description,
            DESCR1         as note
          FROM SYSADM.PS_UCC_SR_LAW_TNOT
          WHERE CAMPUS_ID = '#{uid}'
        SQL
      end
    end
  end
end
