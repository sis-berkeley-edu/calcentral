module DataLoch
  class Zipper

    BATCH_SIZE = 120000
    STAGING_DIRECTORY = Pathname.new Settings.data_loch.staging_directory

    def self.zip_courses(term_id)
      path = staging_path "courses-#{term_id}.gz"
      Zlib::GzipWriter.open(path) do |gz|
        courses = EdoOracle::Bulk.get_courses(term_id)
        zip_query_results(courses, gz)
      end
      path
    end

    def self.zip_enrollments(term_id)
      path = staging_path "enrollments-#{term_id}.gz"
      batch = 0
      Zlib::GzipWriter.open(path) do |gz|
        loop do
          enrollments = EdoOracle::Bulk.get_batch_enrollments(term_id, batch, BATCH_SIZE)
          zip_query_results(enrollments, gz)
          # If we receive fewer rows than the batch size, we've read all available rows and are done.
          break if enrollments.rows.count < BATCH_SIZE
          batch += 1
        end
      end
      path
    end

    def self.zip_query_results(results, gz)
      raise StandardError, 'Enrollments query failed' unless results.respond_to?(:rows)

      columns = results.columns.map &:upcase
      section_id_idx = columns.index 'SECTION_ID'

      results.rows.each do |r|
        # Cast section ids to integers.
        r[section_id_idx] = r[section_id_idx].to_i
        gz.write r.to_csv
      end
    end

    def self.staging_path(basename)
      FileUtils.mkdir_p STAGING_DIRECTORY unless File.exists? STAGING_DIRECTORY
      STAGING_DIRECTORY.join basename
    end

  end
end
