module Oec
  class ReportDiffTask < Task

    include Validator

    attr_accessor :diff_report

    COLUMNS_TO_COMPARE = %w(COURSE_NAME FIRST_NAME LAST_NAME EMAIL_ADDRESS DEPT_FORM EVALUATION_TYPE MODULAR_COURSE START_DATE END_DATE)

    def run_internal
      @confirmations_folder = @remote_drive.find_nested([@term_code, Oec::Folder.confirmations])
      raise UnexpectedDataError, "No department confirmations folder found for term #{@term_code}" unless @confirmations_folder

      Oec::DepartmentMappings.new(term_code: @term_code).by_dept_code(@departments_filter).keys.each do |dept_code|
        if (diff_report = diff_for_department dept_code)
          update_departmental_diff(diff_report, dept_code)
        end
      end
      log_validation_errors
    end

    private

    def update_departmental_diff(updated_diff, dept_code)
      dept_name = Berkeley::Departments.get(dept_code, concise: true)
      unless (dept_confirmation = @remote_drive.find_first_matching_item(dept_name, @confirmations_folder)) &&
             (dept_confirmation_sheet = @remote_drive.spreadsheet_by_id dept_confirmation.id)
        log :error, "Could not find '#{dept_name}' department confirmation sheet to update diff report"
        return
      end

      diff_report_worksheet = (dept_confirmation_sheet.worksheets.find { |w| w.title == 'Diff Report' }) ||
                               dept_confirmation_sheet.add_worksheet('Diff Report', updated_diff.count+1, updated_diff.headers.count)

      if diff_report_worksheet.max_rows <= updated_diff.count
        diff_report_worksheet.max_rows = updated_diff.count + 1
        diff_report_worksheet.save
      end

      # Write header and data rows.
      cell_updates = {}
      updated_diff.headers.each_with_index { |header, x| cell_updates[[1, x+1]] = "'#{header}" }
      updated_diff.each_sorted_with_index do |diff_report_row, y|
        updated_diff.headers.each_with_index { |header, x| cell_updates[[y+2, x+1]] = diff_report_row[header] }
      end
      # If the old worksheet has more rows than the new worksheet, overwrite old values with blanks.
      (updated_diff.count + 1).upto(diff_report_worksheet.rows.count) do |y|
        1.upto(updated_diff.headers.count) { |x| cell_updates[[y, x]] = '' }
      end

      begin
        @remote_drive.update_worksheet(diff_report_worksheet, cell_updates)
        log :debug, "Updated diff report for '#{dept_name}' confirmation sheet"
      rescue Errors::ProxyError => e
        log :error, "Update of diff report for '#{dept_name}' confirmation sheet failed: #{e}"
      end
    end

    def diff_for_department(dept_code)
      diff_report = Oec::DiffReport.new @opts
      dept_name = Berkeley::Departments.get(dept_code, concise: true)
      validate(dept_code, @term_code) do |errors|
        unless (sis_data = csv_row_hash([@term_code, Oec::Folder.sis_imports, "#{datestamp} #{timestamp}", dept_name], dept_code, Oec::SisImportSheet))
          log :warn, "Skipping #{dept_name} diff: no '#{Oec::Folder.sis_imports}' '#{datestamp} #{timestamp}' spreadsheet found"
          return
        end
        unless (dept_data = csv_row_hash([@term_code, Oec::Folder.confirmations, dept_name], dept_code, Oec::CourseConfirmation))
          log :warn, "Skipping #{dept_name} diff: no department confirmation spreadsheet found"
          return
        end
        keys_of_rows_with_diff = []
        intersection = (sis_keys = sis_data.keys) & (dept_keys = dept_data.keys)
        (sis_keys | dept_keys).select do |key|
          if intersection.include? key
            column_with_diff = COLUMNS_TO_COMPARE.detect do |column|
              # Anticipate nil column values
              sis_value = sis_data[key][column].to_s
              dept_value = dept_data[key][column].to_s
              sis_value.casecmp(dept_value) != 0
            end
            keys_of_rows_with_diff << key if column_with_diff
          else
            keys_of_rows_with_diff << key
          end
        end
        log :info, "#{keys_of_rows_with_diff.length} row(s) with diff found in #{@term_code}/departments/#{dept_name}"
        add_rows_to_diff(diff_report, dept_code, sis_data, dept_data, keys_of_rows_with_diff)
      end
      diff_report
    end

    def default_date_time
      date_time_of_most_recent Oec::Folder.sis_imports
    rescue => e
      log :error, "Error retrieving date of last SIS import: #{e.message}\n#{e.backtrace.join "\n\t"}"
      @status = 'Error'
    end

    def add_rows_to_diff(diff_report, dept_code, sis_data, dept_data, keys)
      keys.each do |key|
        sis_row = sis_data[key]
        dept_row = dept_data[key]

        diff_key = key.values_at(:term_yr, :term_cd, :ccn, :ldap_uid).map(&:to_s).reject(&:empty?).join('-')

        diff_row = {
          'DEPT_CODE' => dept_code,
          'KEY' => diff_key
        }

        if !sis_row
          # Add a single row with values from the department sheet.
          diff_report[diff_key] = diff_row.merge(dept_row.slice('LDAP_UID', *COLUMNS_TO_COMPARE)).merge({
            'REASON' => 'Not in SIS'
          })

        elsif !dept_row
          # Add a single row with values from the SIS import sheet.
          COLUMNS_TO_COMPARE.each { |column| diff_row["sis:#{column}"] = sis_row[column] }
          diff_report[diff_key] = diff_row.merge(sis_row.slice('LDAP_UID')).merge({
            'REASON' => 'Not in DCS'
          })

        else
          # Add as many rows as there are discrepancies.
          diff_row.merge!({
            'LDAP_UID' =>        sis_row['LDAP_UID'],
            'COURSE_NAME' =>     dept_row['COURSE_NAME'],
            'sis:COURSE_NAME' => sis_row['COURSE_NAME']
          })
          COLUMNS_TO_COMPARE.each do |column|
            key_with_column = [diff_key, column].join '-'
            if dept_row[column] != sis_row[column]
              diff_report[key_with_column] = diff_row.merge({
                'KEY'           => key_with_column,
                'REASON'        => column,
                column          => dept_row[column],
                "sis:#{column}" => sis_row[column]
              })
            end
          end
        end
      end
    end

    def csv_row_hash(folder_titles, dept_code, klass)
      return unless (file = @remote_drive.find_nested(folder_titles, @opts))
      hash = {}
      csv = @remote_drive.export_csv file
      klass.from_csv(csv, dept_code: dept_code, term_code: @term_code).each do |row|
        begin
          row = Oec::Worksheet.capitalize_keys row
          if (id = extract_id row)
            validate(dept_code, id[:ccn]) do |errors|
              report(errors, id, :annotation, false, %w(A B GSI CHEM MCB))
              report(errors, id, :ldap_uid, false, (1..99999999))
              report(errors, row, 'EVALUATION_TYPE', false, %w(F G LANG SEMI LECT WRIT 1 1A 2 2A 3 3A 4 4A))
              report(errors, row, 'MODULAR_COURSE', false, %w(Y N y n))
              report(errors, row, 'START_DATE', true)
              report(errors, row, 'END_DATE', true)
            end
            hash[id] = row
          else
            log :warn, "#{folder_titles}: No course identifier found in row:\n#{row}"
          end
        rescue => e
          log :error, "#{folder_titles}: Failed to parse a row due to '#{e.message}'.\nThe offending data:\n#{row}"
        end
      end
      hash
    rescue => e
      # We do not tolerate fatal errors when loading CSV file.
      log :error, "\nBoom! Crash! Fatal error in csv_row_hash(#{folder_titles}, #{dept_code}, #{klass})\n"
      raise e
    end


    def report(errors, hash, key, required, range=nil)
      value = (range && range.first.is_a?(Numeric) && /\A\d+\z/.match(hash[key])) ? hash[key].to_i : hash[key]
      return if value.blank? && !required
      unless range.nil? || range.include?(value)
        errors.add(value.nil? ? "#{key} is blank" : "Invalid #{key}: #{value}")
      end
    end

    def extract_id(row)
      return nil unless (course_id = row['COURSE_ID'])
      id = course_id.split '-'
      ccn_plus_tag = id[2].split '_'
      hash = { term_yr: id[0], term_cd: id[1], ccn: ccn_plus_tag[0] }
      hash[:annotation] = ccn_plus_tag[1] if ccn_plus_tag.length == 2
      hash[:ldap_uid] = row['LDAP_UID'] unless row['LDAP_UID'].blank?
      hash
    end

  end
end
