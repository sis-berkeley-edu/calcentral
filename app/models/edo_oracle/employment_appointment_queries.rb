module EdoOracle
  class EmploymentAppointmentQueries < Connection
    include ActiveRecordHelper
    include ClassLogger
    include Concerns::QueryHelper
  
    def self.get_terms_taught(uid)
      result = safe_query <<-SQL
        SELECT UC_TERMS_TAUGHT as terms_count
        FROM SYSADM.PS_UCC_GRTRMTAUGHT
        WHERE CAMPUS_ID = '#{uid}'
      SQL
  
      if result.empty?
        0
      else
        result.first['terms_count'].to_i
      end
    end

    def self.get_appointments(uid)
      safe_query <<-SQL
        SELECT
          DESCR as description,
          DISTRIB_BEGIN_DT as start_date,
          DISTRIB_END_DT as end_date,
          DIST_PCT as distribution_percentage,
          COMPRATE as compenstation,
          UC_L4_DESCR as unit,
          JOBCODE as job_code,
          STEP
        FROM SYSADM.PS_UCC_GRCURAPTVW
        WHERE CAMPUS_ID = '#{uid}'
      SQL
    end
  end
end
