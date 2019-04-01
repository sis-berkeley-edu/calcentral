module CampusOracle
  class Connection < OracleBase
    # WARNING: Default Rails SQL query caching (done for the lifetime of a controller action) apparently does not apply
    # to anything but the primary DB connection. Any Oracle query caching needs to be handled explicitly.

    # Legacy ODS database (CampusOracle) is being deprecated
    # Only enabled in 'test' environment due to large scope of dependent Rspec tests
    # TODO: Refactor Rspec tests that depend on H2 database (see config/initializers/populate_campus_h2.rb)
    establish_connection :campusdb if Rails.env.test?

    def self.settings
      Settings.campusdb
    end

    # This method used to detect any legacy ODS database calls running in a non-test enviroment
    def self.raise_non_test_error
      if Rails.env != 'test'
        error_msg = "CampusOracle Query call detected"
        Rails.logger.error error_msg
        raise StandardError, error_msg
      end
    end

    def self.terms_query_clause(table, terms)
      self.raise_non_test_error

      terms.try :compact!
      if terms.present?
        term_clauses = terms.map do |term|
          "(#{table}.term_cd=#{connection.quote(term.code)} and #{table}.term_yr=#{term.year.to_i})"
        end
        "and (#{term_clauses.join ' or '})"
      else
        ''
      end
    end

    def self.depts_clause(table, departments, inclusive = true)
      self.raise_non_test_error

      string = if departments.blank?
                 ''
               else
                 clause = "and #{table}.dept_name #{'NOT' unless inclusive} IN ("
                 departments.each_with_index do |dept, index|
                   clause.concat("'#{dept}'")
                   clause.concat(",") unless index == departments.length - 1
                 end
                 clause.concat(')')
                 clause
               end
      string
    end

    def self.filter_multi_entry_codes(results)
      self.raise_non_test_error

      # if a course has multiple schedule entries, and the first one's PRINT_CD = "A",
      # then do not display other rows for that course.
      # page 15 of the Class Scheduler User's Guide explains the rationale for this horror:
      # http://registrar.berkeley.edu/DisplayMedia.aspx?ID=Class_Sched_Users_Guide.pdf
      filtered_rows = []
      current_ccn = nil
      current_ccns_first_print_cd = nil
      is_first_row = false
      results.each do |row|
        if current_ccn != row['course_cntl_num']
          current_ccn = row['course_cntl_num']
          current_ccns_first_print_cd = row['print_cd']
          is_first_row = true
        end
        if is_first_row || current_ccns_first_print_cd != 'A'
          filtered_rows << row
        end
        is_first_row = false
      end
      filtered_rows
    end

    def self.stringify_column!(row, column, zero_padding = 0)
      self.raise_non_test_error

      zero_padding = 5 if column == 'course_cntl_num'
      super(row, column, zero_padding)
    end

    def self.stringified_columns
      self.raise_non_test_error

      %w(ldap_uid student_id term_yr catalog_root course_cntl_num student_ldap_uid)
    end
  end
end
