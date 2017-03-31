module Rosters
  class Canvas < Common

    ENROLLMENT_ATTRIBUTE_KEYS = [:student_id, :first_name, :last_name, :email, :enroll_status, :units, :grade_option, :waitlist_position]

    def get_feed_internal
      feed = {
        canvas_course: {
          id: @canvas_course_id
        },
        sections: [],
        students: []
      }
      campus_enrollment_map = {}

      course = ::Canvas::Course.new(canvas_course_id: @canvas_course_id).course
      return feed unless (course_info = course[:body])
      feed[:canvas_course][:name] = course_info['name']

      # Look up Canvas course sections associated with official campus sections.
      official_sections = ::Canvas::CourseSections.new(course_id: @canvas_course_id).official_section_identifiers
      return feed unless official_sections

      term_yr, term_cd = official_sections.first.values_at(:term_yr, :term_cd)
      ccns = official_sections.map { |section| section[:ccn] }
      section_enrollments = get_enrollments(ccns, term_yr, term_cd)

      official_sections.each do |official_section|
        section_ccn = official_section[:ccn]
        sis_id = official_section['sis_section_id']
        feed[:sections] << {
          ccn: section_ccn,
          name: official_section['name'],
          sis_id: sis_id
        }
        section_enrollments[section_ccn].try(:each) do |enr|
          if (existing_entry = campus_enrollment_map[enr[:ldap_uid]])
            existing_entry[:sections] << {id: section_ccn}
            existing_entry[:section_ccns] << section_ccn
            # We include waitlisted students in the roster. However, we do not show the official photo if the student
            # is waitlisted in ALL sections.
            if existing_entry[:enroll_status] == 'W' && enr[:enroll_status] == 'E'
              existing_entry[:enroll_status] = 'E'
            end
          else
            campus_enrollment_map[enr[:ldap_uid]] = enr.slice(*ENROLLMENT_ATTRIBUTE_KEYS).merge({
              sections: [{id: section_ccn}],
              section_ccns: [section_ccn]
            })
          end
        end
      end

      # Create sections hash indexed by CCN
      sections_index = index_by_attribute(feed[:sections], :ccn)

      campus_enrollment_map.each do |ldap_uid, campus_student|
        campus_student[:id] = ldap_uid
        campus_student[:login_id] = ldap_uid
        if campus_student[:enroll_status] == 'E'
          campus_student[:photo] = "/canvas/#{@canvas_course_id}/photo/#{ldap_uid}"
        end

        # Populate sections
        campus_student[:sections] = []
        campus_student[:section_ccns].each do |section_ccn|
          campus_student[:sections].push(sections_index[section_ccn])
        end

        feed[:students] << campus_student
      end

      feed
    end

    def profile_url_for_ldap_id(ldap_id)
      if (user_profile = ::Canvas::SisUserProfile.new(user_id: ldap_id).get) && user_profile['id']
        "#{Settings.canvas_proxy.url_root}/courses/#{@canvas_course_id}/users/#{user_profile['id']}"
      end
    end

  end
end
