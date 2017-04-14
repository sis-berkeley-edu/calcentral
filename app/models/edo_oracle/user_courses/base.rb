module EdoOracle
  module UserCourses
    class Base < BaseProxy

      def initialize(options = {})
        super(Settings.edodb, options)
        @uid = @settings.fake_user_id if @fake
        @non_legacy_academic_terms = Berkeley::Summer16EnrollmentTerms.non_legacy_terms
      end

      def self.access_granted?(uid)
        !uid.blank?
      end

      def merge_enrollments(campus_classes)
        return if @non_legacy_academic_terms.empty?
        previous_item = {}

        EdoOracle::Queries.get_enrolled_sections(@uid, @non_legacy_academic_terms).each do |row|
          if (item = row_to_feed_item(row, previous_item))
            item[:role] = 'Student'
            # Cross-listed courses may lack descriptive names. Students, unlike instructors, will
            # not get the correctly named course elsewhere in their feed.
            merge_cross_listed_titles item
            merge_feed_item(item, campus_classes)
            previous_item = item
          end
        end
      end

      def merge_instructing(campus_classes)
        return if @non_legacy_academic_terms.empty?
        previous_item = {}
        cross_listing_tracker = {}

        EdoOracle::Queries.get_instructing_sections(@uid, @non_legacy_academic_terms).each do |row|
          if (item = row_to_feed_item(row, previous_item, cross_listing_tracker))
            item[:role] = 'Instructor'
            merge_feed_item(item, campus_classes)
            previous_item = item
          end
        end
        merge_implicit_instructing campus_classes
      end

      # This is done in a separate step so that all secondary sections
      # are ordered after explicitly assigned primary sections.
      def merge_implicit_instructing(campus_classes)
        campus_classes.each_value do |term|
          term.each do |course|
            if course[:role] == 'Instructor'
              section_ids = course[:sections].map { |section| section[:ccn] }.to_set
              course[:sections].select { |section| section[:is_primary_section] }.each do |primary|
                EdoOracle::Queries.get_associated_secondary_sections(course[:term_id], primary[:ccn]).each do |row|
                  # Skip duplicates.
                  if section_ids.add? row['section_id']
                    course[:sections] << row_to_section_data(row)
                  end
                end
              end
            end
          end
        end
      end

      def merge_feed_item(item, campus_classes)
        semester_key = item.values_at(:term_yr, :term_cd).join '-'
        campus_classes[semester_key] ||= []
        campus_classes[semester_key] << item
      end

      def row_to_feed_item(row, previous_item, cross_listing_tracker=nil)
        course_item = course_ids_from_row row
        if course_item[:id] == previous_item[:id] && previous_item[:session_code] == Berkeley::TermCodes::SUMMER_SESSIONS[row['session_id']]
          previous_section = previous_item[:sections].last
          # Odd database joins will occasionally give us null course titles, which we can replace from later rows.
          previous_item[:name] = row['course_title'] if previous_item[:name].blank?
          # Duplicate CCNs indicate duplicate section listings. The only possibly useful information in these repeated
          # listings is a more relevant associated-primary ID for secondary sections.
          if (row['section_id'].to_s == previous_section[:ccn]) && !to_boolean(row['primary'])
            primary_ids = previous_item[:sections].map{ |sec| sec[:ccn] if sec[:is_primary_section] }.compact
            if !primary_ids.include?(previous_section[:associated_primary_id]) && primary_ids.include?(row['primary_associated_section_id'])
              previous_section[:associated_primary_id] = row['primary_associated_section_id']
            end
          else
            previous_item[:sections] << row_to_section_data(row, cross_listing_tracker)
            sum_primary_limits(previous_item, row) unless row['enroll_status']
          end
          nil
        else
          term_data = Berkeley::TermCodes.from_edo_id(row['term_id']).merge({
            term_id: row['term_id'],
            session_code: Berkeley::TermCodes::SUMMER_SESSIONS[row['session_id']]
          })
          course_name = row['course_title'].present? ? row['course_title'] : row['course_title_short']
          course_data = {
            emitter: 'Campus',
            name: course_name,
            sections: [
              row_to_section_data(row, cross_listing_tracker)
            ]
          }
          sum_primary_limits(course_data, row) unless row['enroll_status']
          course_item.merge(term_data).merge(course_data)
        end
      end

      def sort_courses(campus_classes)
        campus_classes.each_value do |semester_classes|
          semester_classes.sort_by! { |c| Berkeley::CourseCodes.comparable_course_code c }
        end
      end

      def sum_primary_limits(course_data, row)
        return unless to_boolean(row['primary'])
        course_data[:enroll_limit] ||= 0
        course_data[:waitlist_limit] ||= 0
        course_data[:enroll_limit] += row['enroll_limit'].to_i
        course_data[:waitlist_limit] += row['waitlist_limit'].to_i
      end

      # Create IDs for a given course item:
      #   "id" : unique for the UserCourses feed across terms; used by Classes
      #   "slug" : URL-friendly ID without term information; used by Academics
      #   "course_code" : the short course name as displayed in the UX
      def course_ids_from_row(row)
        dept_name, dept_code, catalog_id = parse_course_code row
        slug = [dept_name, catalog_id].map { |str| normalize_to_slug str }.join '-'
        term_code = Berkeley::TermCodes.edo_id_to_code row['term_id']
        {
          catid: catalog_id,
          course_catalog: catalog_id,
          course_code: "#{dept_name} #{catalog_id}",
          dept: dept_name,
          dept_code: dept_code,
          id: "#{slug}-#{term_code}",
          slug: slug
        }
      end

      def normalize_to_slug(str)
        str.downcase.gsub(/[^a-z0-9-]+/, '_')
      end

      def row_to_section_data(row, cross_listing_tracker=nil)
        section_data = {
          ccn: row['section_id'].to_s,
          instruction_format: row['instruction_format'],
          is_primary_section: to_boolean(row['primary']),
          section_label: "#{row['instruction_format']} #{row['section_num']}",
          section_number: row['section_num']
        }
        if section_data[:is_primary_section]
          section_data[:units] = row['units']
          section_data[:start_date] = row['start_date'] if row['start_date']
          section_data[:end_date] = row['end_date'] if row['end_date']
          section_data[:session_id] = row['session_id'] if row['session_id']
        else
          section_data[:associated_primary_id] = row['primary_associated_section_id']
        end

        if row.include? 'enroll_status'
          # Grading and waitlist data relevant to students.
          section_data[:grade] = row['grade'].strip if row['grade'].present?
          section_data[:grading_basis] = row['grading_basis'] if section_data[:is_primary_section]
          if row['enroll_status'] == 'W'
            section_data[:waitlisted] = true
            section_data[:waitlistPosition] = row['waitlist_position'].to_i
            section_data[:enroll_limit] = row['enroll_limit'].to_i
          end
        else
          # Enrollment and waitlist data relevant to instructors.
          section_data[:enroll_limit] = row['enroll_limit'].to_i
          section_data[:waitlist_limit] = row['waitlist_limit'].to_i
        end

        # Cross-listed primaries are tracked only when merging instructed sections.
        if cross_listing_tracker && section_data[:is_primary_section]
          cross_listing_slug = row.values_at('term_id', 'cs_course_id', 'instruction_format', 'section_num').join '-'
          if (cross_listings = cross_listing_tracker[cross_listing_slug])
            # The front end expects cross-listed primaries to share a unique identifier, called 'hash'
            # because it was formerly implemented as an Oracle hash.
            section_data[:cross_listing_hash] = cross_listing_slug
            if cross_listings.length == 1
              cross_listings.first[:cross_listing_hash] = cross_listing_slug
            end
            cross_listings << section_data
          else
            cross_listing_tracker[cross_listing_slug] = ([] << section_data)
          end
        end

        section_data
      end

      def remove_duplicate_sections(campus_classes)
        campus_classes.each_value do |semester|
          semester.each do |course|
            course[:sections].uniq!
          end
        end
      end

      def merge_cross_listed_titles(course)
        if (course[:catid].start_with? 'C') && !course[:name]
          title_results = self.class.fetch_from_cache "cross_listed_title-#{course[:course_code]}" do
            EdoOracle::Queries.get_cross_listed_course_title course[:course_code]
          end
          if title_results.present?
            course[:name] = title_results['course_title'] || title_results['course_title_short']
          end
        end
      end

      def merge_detailed_section_data(campus_classes)
        # Track instructors as we go to allow an efficient final overwrite with directory attributes.
        instructors_by_uid = {}
        campus_classes.each_value do |semester|
          semester.each do |course|
            course[:sections].uniq!
            course[:sections].each do |section|
              section_data = EdoOracle::CourseSections.new(course[:term_id], section[:ccn]).get_section_data
              section_data[:instructors].each do |instructor_data|
                instructors_by_uid[instructor_data[:uid]] ||= []
                instructors_by_uid[instructor_data[:uid]] << instructor_data
              end
              section.merge! section_data
            end
          end
        end
        User::BasicAttributes.attributes_for_uids(instructors_by_uid.keys).each do |instructor_attributes|
          if (instructor_entries = instructors_by_uid[instructor_attributes[:ldap_uid]])
            instructor_entries.each { |entry| entry[:name] = instructor_attributes.values_at(:first_name, :last_name).join(' ') }
          end
        end
      end

      def to_boolean(string)
        string == 'true'
      end

      # Our underlying database join between sections and courses is shaky, so we need a series of fallbacks.
      def parse_course_code(row)
        subject_area, class_subject_area, catalog_number = row.values_at('dept_name', 'dept_code', 'catalog_id')
        unless subject_area && catalog_number
          display_name = row['course_display_name'] || row['section_display_name']
          subject_area, catalog_number = display_name.rpartition(/\s+/).reject &:blank?
        end
        @subject_areas ||= EdoOracle::SubjectAreas.fetch
        subject_area = @subject_areas.decompress subject_area
        [subject_area, class_subject_area, catalog_number]
      end

    end
  end
end
