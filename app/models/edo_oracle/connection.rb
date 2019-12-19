module EdoOracle
  class Connection < OracleBase

    # WARNING: Default Rails SQL query caching (done for the lifetime of a controller action) apparently does not apply
    # to anything but the primary DB connection. Any Oracle query caching needs to be handled explicitly.
    establish_connection :edodb

    def self.settings
      Settings.edodb
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

    def self.stringified_columns
      %w(campus-uid meeting_num section_id ldap_uid student_id)
    end

    def self.terms_query_list(terms = nil)
      terms.try :compact!
      return '' unless terms.present?
      terms.map { |term| "'#{term.campus_solutions_id}'" }.join ','
    end
  end
end
