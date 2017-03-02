module MyAcademics
  class Teaching
    include AcademicsModule

    def merge(data)
      feed = EdoOracle::UserCourses::All.new(user_id: @uid).get_all_campus_courses
      feed.merge!  CampusOracle::UserCourses::All.new(user_id: @uid).get_all_campus_courses if Settings.features.allow_legacy_fallback

      teaching_semesters = format_teaching_semesters feed
      if teaching_semesters.present?
        data[:teachingSemesters] = teaching_semesters
        data[:pastSemestersTeachingCount] = teaching_semesters.select {|sem| sem[:timeBucket] == 'past'}.length
        data[:pastSemestersTeachingLimit] = teaching_semesters.length - data[:pastSemestersTeachingCount] + 1;
      end
    end

    # Our bCourses Canvas integration occasionally needs to create an Academics Teaching Semesters
    # list based on an explicit set of CCNs.
    def courses_list_from_ccns(term_yr, term_code, ccns)
      if Berkeley::Terms.legacy?(term_yr, term_code) && Settings.features.allow_legacy_fallback
        proxy = CampusOracle::UserCourses::SelectedSections.new({user_id: @uid})
      else
        proxy = EdoOracle::UserCourses::SelectedSections.new({user_id: @uid})
      end
      feed = proxy.get_selected_sections(term_yr, term_code, ccns)
      format_teaching_semesters(feed, true)
    end

    def format_teaching_semesters(sections_data, ignore_roles = false)
      teaching_semesters = []
      # The campus courses data is organized by semesters, with course offerings under them.
      sections_data.keys.sort.reverse_each do |term_key|
        teaching_semester = semester_info term_key
        sections_data[term_key].each do |course|
          next unless ignore_roles || (course[:role] == 'Instructor')
          course_info = course_info_with_multiple_listings course
          course_info.merge! enrollment_limits(course)
          if course_info[:sections].count { |section| section[:is_primary_section] } > 1
            merge_multiple_primaries(course_info, course[:course_option])
          end
          append_with_merged_crosslistings(teaching_semester[:classes], course_info)
        end
        teaching_semesters << teaching_semester unless teaching_semester[:classes].empty?
      end
      teaching_semesters
    end

    def enrollment_limits(course)
      {
        enrollLimit: course[:enroll_limit],
        waitlistLimit: course[:waitlist_limit]
      }
    end

  end
end
