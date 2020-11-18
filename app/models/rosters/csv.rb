module Rosters
  class Csv < Common
    def initialize(rosters_feed, opts = {})
      @students = rosters_feed.try(:[], :students)
      @sections = rosters_feed.try(:[], :sections)
      @campus_course_id = opts[:campus_course_id] if opts[:campus_course_id].present?
      @section_id = opts[:section_id] if opts[:section_id].present?
      @enroll_option = opts[:enroll_option] if opts[:enroll_option].present?
      filter_students_by_options
    end

    def is_crosslisted_course?
      @is_crosslisted_course ||= !!@sections.to_a.find { |sec| !!sec.try(:[], :cross_listing) }
    end

    def get_filename
      section_string = "_#{section_label}" if @section_id.present?
      enroll_option_string = "_#{@enroll_option}" if @enroll_option.present? && @enroll_option != 'all'
      "#{@campus_course_id}#{section_string}#{enroll_option_string}_rosters.csv"
    end

    def section_label
      section_label = nil
      if @section_id.present?
        matching_section = @sections.find {|sec| sec.try(:[], :ccn) == @section_id }
        section_label = matching_section.try(:[], :section_label).to_s.gsub(/\s+/, '-')
      end
      section_label
    end

    def get_csv
      CSV.generate(headers: true, force_quotes: true) do |csv|
        section_column_headers = @students.try(:first).try(:[], :columns).try(:map) {|sec| sec[:instruction_format].to_s } || []
        crosslisted_course_name_column = []
        crosslisted_course_name_column.push('Course') if is_crosslisted_course?
        csv << [
          'Name',
          'Student ID',
          'User ID',
          'Role',
          'Email Address',
          crosslisted_course_name_column,
          section_column_headers,
          'Majors',
          'Terms in Attendance',
          'Units',
          'Grading Basis',
          'Waitlist Position'
        ].flatten
        @students.each do |student|
          course_name_value = []
          if is_crosslisted_course?
            course_name = student.try(:[], :sections).try(:first).try(:[], :course_name)
            course_name_value.push(course_name)
          end
          name = student[:last_name] + ', ' + student[:first_name]
          user_id = student[:login_id]
          student_id = student[:student_id]
          email_address = student[:email]
          role = Campus::ENROLL_STATUS_TO_CSV_ROLE[student[:enroll_status]]
          section_column_values = student.try(:[], :columns).try(:map) {|sec| sec[:section_number].to_s } || []
          majors = student[:majors].try(:sort).try(:join, ', ')
          terms_in_attendance = student[:terms_in_attendance]
          units = student[:units]
          grade_option = student[:grade_option]
          waitlist_position = student[:waitlist_position] || ''
          row = [
            name,
            student_id,
            user_id,
            role,
            email_address,
            course_name_value,
            section_column_values,
            majors,
            terms_in_attendance,
            units,
            grade_option,
            waitlist_position,
          ].flatten
          csv << row
        end
      end
    end

    def filter_students_by_options
      filter_students_by_section_id(@students, @section_id) if @section_id.present?
      filter_students_by_enroll_option(@students, @enroll_option) if @enroll_option.present?
    end

    def filter_students_by_section_id(students, section_id)
      if students.present? && section_id.present?
        students = students.select! do |student|
          student[:section_ccns].include?(section_id.to_s)
        end
      end
    end

    def filter_students_by_enroll_option(students, enroll_option)
      if students.present? && enroll_option.present?
        if enroll_option == 'enrolled'
          students = students.select! {|s| s[:enroll_status] == 'E'}
        elsif enroll_option == 'waitlisted'
          students = students.select! {|s| s[:enroll_status] == 'W'}
        end
      end
      students
    end
  end
end
