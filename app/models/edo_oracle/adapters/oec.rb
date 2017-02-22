module EdoOracle
  module Adapters
    class Oec
      extend EdoOracle::Adapters::Common

      def self.adapt_courses(rows, term_code)
        default_dates = get_default_dates term_code
        user_courses = EdoOracle::UserCourses::Base.new
        supplement_user_attributes rows

        rows.each do |row|
          uniq_ccn_lists row

          adapt_dept_name_and_catalog_id(row, user_courses)
          adapt_course_name row

          adapt_course_cntl_num row
          adapt_course_id(row, term_code)
          adapt_cross_listed_flag row
          adapt_dates(row, default_dates)
          adapt_instructor_func row
          adapt_primary_secondary_cd row
          adapt_sis_id row

          row['blue_role'] = '23'
        end
      end

      def self.adapt_enrollment_row(row, columns, term_code)
        hash_row = Hash[columns.zip row]
        hash_row['COURSE_ID'] = "#{term_code}-#{hash_row['SECTION_ID']}"
        hash_row
      end

      def self.supplement_user_attributes(rows, columns=nil)
        # Depending on source query, the 'rows' argument may be an array of hashes (in which case we retrieve values
        # using string keys), or an array of arrays (in which case we pass in an additional 'columns' argument and
        # retrieve values using integer indexes).
        email_address_key = columns ? columns.index('EMAIL_ADDRESS') : 'email_address'
        ldap_uid_key = columns ? columns.index('LDAP_UID') : 'ldap_uid'
        first_name_key = columns ? columns.index('FIRST_NAME') : 'first_name'
        last_name_key = columns ? columns.index('LAST_NAME') : 'last_name'

        rows_without_email = {}
        rows_without_names = {}

        rows.each do |row|
          next if row[ldap_uid_key].blank?
          if row[email_address_key].blank?
            rows_without_email[row[ldap_uid_key].to_s] ||= []
            rows_without_email[row[ldap_uid_key].to_s] << row
          end
          if row[last_name_key].blank?
            rows_without_names[row[ldap_uid_key].to_s] ||= []
            rows_without_names[row[ldap_uid_key].to_s] << row
          end
        end

        User::BasicAttributes.attributes_for_uids(rows_without_email.keys).each do |attrs|
          rows_without_email[attrs[:ldap_uid]].each do |row|
            row[email_address_key] = attrs[:email_address]
          end
        end

        User::BasicAttributes.attributes_for_uids(rows_without_names.keys).each do |attrs|
          rows_without_names[attrs[:ldap_uid]].each do |row|
            row[first_name_key] = attrs[:first_name]
            row[last_name_key] = attrs[:last_name]
          end
        end
      end

      def self.get_default_dates(term_code)
        slug = Berkeley::TermCodes.to_slug *term_code.split('-')
        term = Berkeley::Terms.fetch.campus[slug]
        {
          start: term.classes_start.to_date,
          end: term.instruction_end.to_date
        }
      end

      def self.adapt_course_id(row, term_code)
        if row['section_id']
          row['course_id'] = "#{term_code}-#{row.delete 'section_id'}"
        end
      end

      def self.adapt_course_name(row)
        if row['dept_name']
          row['course_name'] = row.values_at('dept_name', 'catalog_id', 'instruction_format', 'section_num', 'course_title_short').join ' '
        end
      end

      def self.adapt_cross_listed_flag(row)
        row['cross_listed_flag'] = 'Y' if row['cross_listed_ccns'].present?
      end

      def self.adapt_dates(row, default_dates)
        if (row['start_date'] && row['end_date'])
          if (row['start_date'].to_date == default_dates[:start] && row['end_date'].to_date == default_dates[:end])
            row.delete 'start_date'
            row.delete 'end_date'
          else
            row['modular_course'] = 'Y'
            row['start_date'] = row['start_date'].strftime ::Oec::Worksheet::WORKSHEET_DATE_FORMAT
            row['end_date'] = row['end_date'].strftime ::Oec::Worksheet::WORKSHEET_DATE_FORMAT
          end
        end
      end

      def self.adapt_sis_id(row)
        unless row['affiliations'] && row['affiliations'].include?('STUDENT')
          row['sis_id'] = row['ldap_uid'] ? "UID:#{row['ldap_uid']}" : nil
        end
      end

      def self.uniq_ccn_lists(row)
        %w(co_scheduled_ccns cross_listed_ccns).each do |key|
          next unless row[key].present?
          ccns = row[key].split(',').uniq
          if ccns.count > 1
            row[key] = ccns.join(',')
          else
            row.delete key
          end
        end
      end

    end
  end
end
