module DataLoch
  class Zipper

    BATCH_SIZE = 120000
    STAGING_DIRECTORY = Pathname.new Settings.data_loch.staging_directory

    def self.zip_query(base_path)
      path = staging_path "#{base_path}.gz"
      Zlib::GzipWriter.open(path) do |gz|
        rows = yield
        zip_query_results(rows, gz)
      end
      path
    end

    def self.zip_query_batched(base_path)
      path = staging_path "#{base_path}.gz"
      batch = 0
      Zlib::GzipWriter.open(path) do |gz|
        result = yield(batch, BATCH_SIZE)
        zip_query_results(result, gz)
        # If we receive fewer rows than the batch size, we've read all available rows and are done.
        break if result.rows.count < BATCH_SIZE
        batch += 1
      end
      path
    end

    def self.zip_query_results(results, gz)
      raise StandardError, 'DB query failed' unless results.respond_to?(:rows)

      columns = results.columns.map &:downcase
      intified_idxs = intified_cols.map {|name| columns.index name}.compact
      results.rows.each do |r|
        intified_idxs.each do |idx|
          raw = r[idx]
          next if raw.nil? || raw.is_a?(String)
          r[idx] = raw.to_i
        end
        gz.write r.to_csv
      end
    end

    # Cast BigDecimals and suchlike to integers.
    def self.intified_cols
      %w(sid parent_income test_score_nbr applied_school_yr)
    end

    def self.staging_path(basename)
      FileUtils.mkdir_p STAGING_DIRECTORY unless File.exists? STAGING_DIRECTORY
      STAGING_DIRECTORY.join(basename).to_s
    end

  end
end
