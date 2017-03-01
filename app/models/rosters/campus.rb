module Rosters
  class Campus < Common
    include ClassLogger

    def get_feed_internal
      feed = {
        campus_course: {
          id: "#{@campus_course_id}"
        },
        sections: [],
        students: []
      }
      all_courses = EdoOracle::UserCourses::All.new({user_id: @uid}).get_all_campus_courses
      all_courses.merge!  CampusOracle::UserCourses::All.new(user_id: @uid).get_all_campus_courses if Settings.features.allow_legacy_fallback

      selected_term, selected_course = nil
      all_courses.each do |term, courses|
        if (course = courses.find {|c| (c[:id] == @campus_course_id) && (c[:role] == 'Instructor') })
          selected_term = term
          selected_course = course
          break
        end
      end

      return feed if selected_course.nil?
      term_yr, term_cd = selected_term.split '-'

      feed[:campus_course].merge!(name: selected_course[:name])

      crosslisted_courses = []
      if (crosslisted_section = selected_course[:sections].find { |section| section[:cross_listing_hash].present? })
        crosslisting_hash = crosslisted_section[:cross_listing_hash]
        crosslisted_courses = all_courses[selected_term].select do |course|
          course[:sections].find { |section| section[:cross_listing_hash] == crosslisting_hash }
        end
      else
        crosslisted_courses << selected_course
      end

      campus_enrollment_map = {}
      ccns = crosslisted_courses.map { |course| course[:sections].map { |section| section[:ccn] } }.flatten
      enrollments = get_enrollments(ccns, term_yr, term_cd)

      crosslisted_courses.each do |course|
        course[:sections].each do |section|
          recurring_schedules = section.try(:[], :schedules).try(:[], :recurring).to_a
          section_locations, section_dates = [], []

          # calculate enrollment statistics
          section_enrollment_limit = section[:enroll_limit].to_i
          section_waitlist_limit = section[:waitlist_limit].to_i

          section_enrolled_count, section_waitlisted_count = 0, 0
          if (section_enrollments = enrollments[section[:ccn]])
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
            section_enrolled_count = 0
            section_waitlisted_open = section_waitlist_limit
            section_waitlisted_count = 0
          end

          if (recurring_schedules.size > 0)
            section_dates = recurring_schedules.map {|schedule| schedule[:schedule]}
            section_locations = recurring_schedules.map {|schedule| "#{schedule[:roomNumber]} #{schedule[:buildingName]}"}
          end
          feed[:sections] << {
            ccn: section[:ccn],
            name: "#{course[:dept]} #{course[:catid]} #{section[:section_label]}",
            section_label: section[:section_label].to_s,
            locations: section_locations,
            dates: section_dates,
            is_primary: section[:is_primary_section],
            enroll_limit: section_enrollment_limit,
            enroll_count: section_enrolled_count,
            enroll_open: section_enrollments_open,
            waitlist_limit: section_waitlist_limit,
            waitlist_count: section_waitlisted_count,
            waitlist_open: section_waitlisted_open
          }
          enrollments[section[:ccn]].try(:each) do |enr|
            if (existing_entry = campus_enrollment_map[enr[:ldap_uid]])
              # We include waitlisted students in the roster. However, we do not show the official photo if the student
              # is waitlisted in ALL sections.
              if existing_entry[:enroll_status] == 'W' && enr[:enroll_status] == 'E'
                existing_entry[:enroll_status] = 'E'
              end
              campus_enrollment_map[enr[:ldap_uid]][:section_ccns] |= [section[:ccn]]
            else
              campus_enrollment_map[enr[:ldap_uid]] = enr.slice(:student_id, :first_name, :last_name, :email, :enroll_status, :majors, :terms_in_attendance, :academic_career).merge({
                section_ccns: [section[:ccn]]
              })
            end
            # Grading and waitlist information in the enrollment summary view should apply to the graded component.
            if enr[:grade_option].present? && enr[:units].to_f.nonzero?
              campus_enrollment_map[enr[:ldap_uid]].merge! enr.slice(:grade_option, :units, :waitlist_position)
            end
          end
        end
      end

      # Create sections hash indexed by CCN
      sections_index = index_by_attribute(feed[:sections], :ccn)

      return feed if campus_enrollment_map.empty?
      campus_enrollment_map.keys.each do |id|
        campus_student = campus_enrollment_map[id]
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
        feed[:students] << campus_student
      end
      feed
    end

  end
end
