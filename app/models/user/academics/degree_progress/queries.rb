module User
  module Academics
    module DegreeProgress
      class Queries < ::EdoOracle::Connection
        include ActiveRecordHelper
        def self.candidacy_term_status(emplid)
          query = <<-SQL
            SELECT
              EMPLID as emplid,
              ACAD_CAREER as acad_career,
              ACAD_PROG as acad_prog,
              ACAD_PLAN as acad_plan,
              ACAD_SUB_PLAN as acad_sub_plan,
              UC_CANDCY_END_TERM as candidacy_end_term,
              UC_CANDIDACY_STAT as candidacy_status_code
            FROM SYSADM.PS_UCC_CAND_TRMSTA
            WHERE
              INSTITUTION = '#{ Concerns::QueryHelper::UC_BERKELEY }'
              AND EMPLID = '#{emplid}'
          SQL
          safe_query(query)
        end
      end
    end
  end
end
