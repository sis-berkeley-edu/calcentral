module Oec
  module Queries
    extend self

    # Only used in SisImportTask.import_courses
    def courses_for_codes(term_code, course_codes, import_all = false)
      return [] unless (filter = EdoOracle::Oec.depts_clause(term_code, course_codes, import_all))
      get_courses(term_code, filter)
    end

    def courses_for_cntl_nums(term_code, ccns)
      return [] unless ccns.present? && (filter = EdoOracle::Oec.chunked_whitelist(EdoOracle::Oec.course_ccn_column, ccns))
      get_courses(term_code, filter)
    end

    def get_courses(term_code, filter)
      term_id = EdoOracle::Adapters::Oec.term_id term_code
      rows = EdoOracle::Oec.get_courses(term_id, filter)
      EdoOracle::Adapters::Oec.adapt_courses(rows, term_code)
    end

    # The number of section IDs under evaluation tends to be large enough that it's more efficient to query for all
    # enrollments in the term and then filter results in code. Owing to the size of the result set, we execute the
    # query in batches and return result rows as arrays, not hashes.
    def get_enrollments(term_code, section_ids)
      term_id = EdoOracle::Adapters::Oec.term_id term_code
      columns = nil
      rows = []
      batch = 0

      loop do
        enrollments = EdoOracle::Oec.get_batch_enrollments(term_id, batch, Settings.oec.enrollments_batch_size)
        raise StandardError, 'Enrollments query failed' unless enrollments.respond_to?(:columns) && enrollments.respond_to?(:rows)

        columns ||= enrollments.columns.map &:upcase
        section_id_idx = columns.index 'SECTION_ID'

        enrollments.rows.each do |enrollment_row|
          string_section_id = enrollment_row[section_id_idx].to_i.to_s
          if section_ids.include? string_section_id
            # Since we skipped OracleBase.stringify_ints! in the upstream query, stringify section IDs now.
            enrollment_row[section_id_idx] = string_section_id
            rows << enrollment_row
          end
        end

        # If we receive fewer rows than the batch size, we've read all available rows and are done.
        break if enrollments.rows.count < Settings.oec.enrollments_batch_size
        batch += 1
      end

      EdoOracle::Adapters::Oec.supplement_user_attributes(rows, columns)

      {
        rows: rows,
        columns: columns
      }
    end

  end
end
