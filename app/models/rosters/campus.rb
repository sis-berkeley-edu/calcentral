module Rosters
  class Campus < Common
    include ClassLogger

    def all_courses
      worker = Proc.new do
        all_courses = EdoOracle::UserCourses::All.new({user_id: @uid}).get_all_campus_courses
        all_courses.merge! CampusOracle::UserCourses::All.new(user_id: @uid).get_all_campus_courses if Settings.features.allow_legacy_fallback
        all_courses
      end
      @all_users_courses ||= worker.call
    end

    def get_campus_course
      matching_term, matching_course = nil
      all_courses.each do |term, courses|
        if (course = courses.find {|c| (c[:id] == @campus_course_id) && (c[:role] == 'Instructor') })
          matching_term = term
          matching_course = course
          break
        end
      end
      {
        course: matching_course,
        term: matching_term
      }
    end

    # Obtains courses with matching crosslisted sections
    def get_crosslisted_courses(selected_course, term_courses)
      crosslisted_courses = []
      # if sections found with cross listing hash, find and include matching courses
      if (crosslisted_section = selected_course[:sections].find { |section| section[:cross_listing_hash].present? })
        crosslisting_hash = crosslisted_section[:cross_listing_hash]
        crosslisted_courses = term_courses.select do |course|
          course[:sections].find { |section| section[:cross_listing_hash] == crosslisting_hash }
        end
      else
        crosslisted_courses << selected_course
      end
      crosslisted_courses
    end

    def get_section_stats(section, section_enrollments)
      section_enrolled_count, section_enrollments_open = 0, 0
      section_waitlisted_count, section_waitlisted_open = 0, 0
      section_enrollment_limit = section[:enroll_limit].to_i
      section_waitlist_limit = section[:waitlist_limit].to_i

      if (section_enrollments)
        section_enrollments_grouped = section_enrollments.group_by { |e| e[:enroll_status] != 'E' ? :waitlisted : :enrolled }
        section_waitlisted_count = section_enrollments_grouped[:waitlisted].try(:length).to_i
        section_enrolled_count = section_enrollments_grouped[:enrolled].try(:length).to_i

        section_enrollments_open = section_enrollment_limit - section_enrolled_count
        section_waitlisted_open = section_waitlist_limit - section_waitlisted_count
        if (section_enrollments_open < 0)
          logger.debug "Section Enrollment limit exceeded in Section ID #{section[:ccn]}; Enrollment Count: #{section_enrolled_count}; Limit: #{section_enrollment_limit}"
          section_enrollments_open = 0
        end
        if (section_waitlisted_open < 0)
          logger.debug "Section Waitlist limit exceeded in Section ID #{section[:ccn]}; Waitlist Count: #{section_waitlisted_count}; Limit: #{section_waitlist_limit}"
          section_waitlisted_open = 0
        end
      else
        section_enrollments_open = section_enrollment_limit
        section_waitlisted_open = section_waitlist_limit
      end
      {
        enrolled: {
          open: section_enrollments_open,
          count: section_enrolled_count,
          limit: section_enrollment_limit
        },
        waitlisted: {
          open: section_waitlisted_open,
          count: section_waitlisted_count,
          limit: section_waitlist_limit
        }
      }
    end

    def recurring_schedules(section)
      section.try(:[], :schedules).try(:[], :recurring).to_a
    end

    # Returns array of section locations
    def section_locations(section)
      schedules = recurring_schedules(section)
      schedules.size > 0 ? schedules.map {|schedule| "#{schedule[:roomNumber]} #{schedule[:buildingName]}"} : []
    end

    # Returns array of section dates
    def section_dates(section)
      schedules = recurring_schedules(section)
      schedules.size > 0 ? schedules.map {|schedule| schedule[:schedule]} : []
    end

    # Maps data from a sections enrollments to an enrollment map
    # Required to apply special logic concerning enrollment status for waitlisted students
    # Note: @campus_enrollment_map should be initialized before a course's sections are mapped
    def apply_section_enrollments_to_enrollment_map(section, section_enrollments)
      @campus_enrollment_map ||= {}
      section_enrollments.try(:each) do |enrollment|
        if (existing_entry = @campus_enrollment_map[enrollment[:ldap_uid]])
          # We include waitlisted students in the roster. However, we do not show the official photo if the student
          # is waitlisted in ALL sections.
          if existing_entry[:enroll_status] == 'W' && enrollment[:enroll_status] == 'E'
            existing_entry[:enroll_status] = 'E'
          end
          @campus_enrollment_map[enrollment[:ldap_uid]][:section_ccns] |= [section[:ccn]]
        else
          @campus_enrollment_map[enrollment[:ldap_uid]] = enrollment.slice(:student_id, :first_name, :last_name, :email, :enroll_status, :majors, :terms_in_attendance, :academic_career).merge({
            section_ccns: [section[:ccn]]
          })
        end
        # Grading and waitlist information in the enrollment summary view should apply to the graded component.
        if enrollment[:grade_option].present? && enrollment[:units].to_f.nonzero?
          @campus_enrollment_map[enrollment[:ldap_uid]].merge! enrollment.slice(:grade_option, :units, :waitlist_position)
        end
      end
      @campus_enrollment_map
    end

    def get_mapped_students(sections)
      # Create sections hash indexed by CCN
      sections_index = index_by_attribute(sections, :ccn)
      mapped_students = []
      @campus_enrollment_map.keys.each do |id|
        campus_student = @campus_enrollment_map[id]
        campus_student[:id] = id
        campus_student[:login_id] = id
        campus_student[:profile_url] = 'http://www.berkeley.edu/directory/results?search-type=uid&search-base=all&search-term=' + id
        campus_student[:sections] = []
        campus_student[:section_ccns].each do |section_ccn|
          campus_student[:sections].push(sections_index[section_ccn])
        end

        if campus_student[:enroll_status] == 'E'
          campus_student[:photo] = "/campus/#{@campus_course_id}/photo/#{id}"
        end
        mapped_students << campus_student
      end
      mapped_students
    end

    def get_feed_internal
      # init enrollment map, see #apply_section_enrollments_to_enrollment_map
      @campus_enrollment_map = {}

      feed = {
        campus_course: {
          id: "#{@campus_course_id}"
        },
        sections: [],
        students: []
      }

      campus_course = get_campus_course
      selected_course = campus_course[:course]
      selected_term = campus_course[:term]

      return feed if selected_course.nil?
      feed[:campus_course].merge!(name: selected_course[:name])
      term_yr, term_cd = selected_term.split '-'

      crosslisted_courses = get_crosslisted_courses(selected_course, all_courses[selected_term])
      ccns = crosslisted_courses.map { |course| course[:sections].map { |section| section[:ccn] } }.flatten

      enrollments = get_enrollments(ccns, term_yr, term_cd)

      crosslisted_courses.each do |course|
        course[:sections].each do |section|

          # Process Section
          section_enrollments = enrollments[section[:ccn]]
          section_stats = get_section_stats(section, section_enrollments)
          feed[:sections] << {
            ccn: section[:ccn],
            name: "#{course[:dept]} #{course[:catid]} #{section[:section_label]}",
            section_label: section[:section_label].to_s,
            section_number: section[:section_number].to_s,
            instruction_format: section[:instruction_format].to_s,
            locations: section_locations(section),
            dates: section_dates(section),
            is_primary: section[:is_primary_section],
            enroll_limit: section_stats[:enrolled][:limit],
            enroll_count: section_stats[:enrolled][:count],
            enroll_open: section_stats[:enrolled][:open],
            waitlist_limit: section_stats[:waitlisted][:limit],
            waitlist_count: section_stats[:waitlisted][:count],
            waitlist_open: section_stats[:waitlisted][:open]
          }

          # apply section enrollments to map
          apply_section_enrollments_to_enrollment_map(section, section_enrollments)
        end
      end

      feed[:students] = get_mapped_students(feed[:sections]) unless @campus_enrollment_map.empty?
      student_columns_and_headers = TableColumns.get_students_with_columns_and_headers(feed[:students])
      feed[:students] = student_columns_and_headers[:students]
      feed[:columnHeaders] = student_columns_and_headers[:headers]
      feed
    end

  end
end
