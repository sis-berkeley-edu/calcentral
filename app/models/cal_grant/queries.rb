module CalGrant
  class Queries < ::EdoOracle::Connection
    include ActiveRecordHelper
    include ClassLogger
    include Concerns::QueryHelper

    def self.get_activity_guides(uid)
      safe_query <<-SQL
        SELECT
          PTAI_ITEM_ID as id,
          STRM as term_id,
          ACKNLDG_STATUS as status
        FROM SYSADM.PS_UCC_AG_FA001_VW
        WHERE CAMPUS_ID = '#{uid}'
      SQL
    end
  end
end 
