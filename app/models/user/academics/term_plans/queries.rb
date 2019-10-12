module User
  module Academics
    module TermPlans
      class Queries < ::EdoOracle::Connection
        include ActiveRecordHelper
        include Concerns::QueryHelper

        def self.get_student_term_cpp(student_id)
          query = <<-SQL
            SELECT
              TERM_ID as term_id,
              ACAD_CAREER_CODE as acad_career,
              ACAD_CAREER_DESCR as acad_career_descr,
              ACAD_PROGRAM as acad_program,
              ACAD_PLAN as acad_plan
            FROM SISEDO.STUDENT_TERM_CPPV00_VW
            WHERE
              INSTITUTION = '#{UC_BERKELEY}' AND
              STUDENT_ID = '#{student_id}'
            ORDER BY TERM_ID DESC
          SQL
          safe_query(query)
        end

      end
    end
  end
end
