module User
  module Academics
    class Queries < ::EdoOracle::Connection
      include ActiveRecordHelper

      def self.student_groups(student_id)
        query = <<-SQL
          SELECT
            STDNT_GROUP as student_group_code,
            STDNT_GROUP_DESCR as student_group_description,
            STDNT_GROUP_FROMDATE as from_date
          FROM SISEDO.STUDENT_GROUPV01_VW
          WHERE STUDENT_ID = '#{student_id}'
        SQL
        safe_query(query)
      end
    end
  end
end
