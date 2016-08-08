module Rosters
  class Common
    extend Cache::Cacheable

    # Roles used with Canvas SIS Import API
    ENROLL_STATUS_TO_CSV_ROLE = {
      'E' => 'Student',
      'W' => 'Waitlist Student',
      'C' => 'Concurrent Student'
    }

    def initialize(uid, options={})
      @uid = uid
      @course_id = options[:course_id]
      @campus_course_id = @course_id
      @canvas_course_id = @course_id
    end

    def get_feed
      self.class.fetch_from_cache "#{@course_id}-#{@uid}" do
        get_feed_internal
      end
    end

    # Serves rosters in CSV format
    def get_csv
      CSV.generate do |csv|
        csv << ['Name','Student ID','User ID','Role','Email Address','Sections','Majors','Terms in Attendance']
        get_feed[:students].each do |student|
          name = student[:last_name] + ', ' + student[:first_name]
          user_id = student[:login_id]
          student_id = student[:student_id]
          email_address = student[:email]
          role = ENROLL_STATUS_TO_CSV_ROLE[student[:enroll_status]]
          sections = sections_to_name_string(student[:sections])
          terms_in_attendance = student[:terms_in_attendance]
          majors = student[:majors].try(:sort).try(:join, ', ')
          csv << [name, student_id, user_id, role, email_address, sections, majors, terms_in_attendance]
        end
      end
    end

    def photo_data_or_file(student_id)
      return nil unless roster = get_feed
      if (student = roster[:students].find { |stu| stu[:id].to_s == student_id.to_s }) && student[:enroll_status] == 'E'
        photo_feed = Cal1card::Photo.new(student[:login_id]).get_feed
        if photo_feed[:photo]
          {
            size: photo_feed[:length],
            data: photo_feed[:photo]
          }
        end
      end
    end

    def index_by_attribute(array_of_hashes, key)
      Hash[array_of_hashes.map { |s| [s[key], s] }]
    end

    def sections_to_name_string(sections)
      sections.map {|section| section[:name]}.sort.join(', ')
    end

    def get_enrollments(ccns, term_yr, term_cd)
      if Berkeley::Terms.legacy?(term_yr, term_cd)
        enrollments = CampusOracle::Queries.get_enrolled_students_for_ccns(ccns, term_yr, term_cd).map do |row|
          {
            ccn: row['course_cntl_num'],
            ldap_uid: row['ldap_uid'],
            student_id: row['student_id'],
            first_name: row['first_name'],
            last_name: row['last_name'],
            email: row['student_email_address'],
            enroll_status: row['enroll_status']
          }
        end
        enrollments.group_by { |enrollment| enrollment[:ccn] }
      else
        term_id = Berkeley::TermCodes.to_edo_id(term_yr, term_cd)
        enrollments = {}
        EdoOracle::Queries.get_rosters(ccns, term_id).group_by { |row| row['section_id'] }.each do |section_id, section_enrollments|
          section_enrollments_by_uid = section_enrollments.group_by { |row| row['ldap_uid'] }
          enrollments[section_id] = User::BasicAttributes.attributes_for_uids section_enrollments_by_uid.keys
          enrollments[section_id].each do |attrs|
            attrs[:email] = attrs.delete :email_address
            attrs[:majors] = section_enrollments_by_uid[attrs[:ldap_uid]].collect { |e| e['major'] }.uniq
            if (enrollment_row = section_enrollments_by_uid[attrs[:ldap_uid]].first)
              attrs[:student_id] = enrollment_row['student_id']
              attrs[:terms_in_attendance] = terms_in_attendance_code(enrollment_row['academic_career'], enrollment_row['terms_in_attendance_group'])
              attrs[:enroll_status] = enrollment_row['enroll_status']
              attrs[:grade_option] = Berkeley::GradeOptions.grade_option_from_basis enrollment_row['grading_basis']
              attrs[:units] = enrollment_row['units'].to_s
              attrs[:academic_career] = enrollment_row['academic_career']
              if enrollment_row['enroll_status'] == 'W'
                attrs[:waitlist_position] = enrollment_row['waitlist_position'].to_i
              end
            end
          end
        end
        enrollments
      end
    end

    def terms_in_attendance_code(academic_career, terms_in_attendance_group)
      terms_count = terms_in_attendance_group.try(:[], 1)
      case academic_career
        when 'GRAD', 'LAW'
          'G'
        when 'UGRD'
          terms_count || 'U'
        when 'UCBX'
          "\u2014"
        else
          nil
      end
    end

  end
end
