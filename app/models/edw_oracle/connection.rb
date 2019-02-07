module EdwOracle
  class Connection < OracleBase
    include ActiveRecordHelper
    include ClassLogger

    # WARNING: Default Rails SQL query caching (done for the lifetime of a controller action) apparently does not apply
    # to anything but the primary DB connection. Any Oracle query caching needs to be handled explicitly.
    establish_connection :edw_db

    def self.settings
      Settings.edw_db
    end

    def self.query(sql, opts={})
      result = []
      use_pooled_connection do
        result = connection.select_all sql
      end
      opts[:do_not_stringify] ? result : stringify_ints!(result)
    end

    def self.safe_query(sql, opts={})
      query(sql, opts)
    rescue => e
      logger.error "Query failed: #{e.class}: #{e.message}\n #{e.backtrace.join("\n ")}"
      []
    end

    def self.fallible_query(sql, opts={})
      query(sql, opts)
    rescue => e
      logger.fatal "Query failed: #{e.class}: #{e.message}\n #{e.backtrace.join("\n ")}"
      raise RuntimeError, "Fatal database failure"
    end

    def self.stringified_columns
      %w(sid parent_income test_score_nbr applied_school_yr)
    end
  end
end
