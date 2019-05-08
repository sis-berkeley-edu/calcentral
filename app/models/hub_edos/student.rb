module HubEdos
  class Student
    def initialize(uid)
      @uid = uid
    end

    def max_terms_in_attendance
      if statuses = student_data[:feed]['academicStatuses']
        return statuses.collect {|s| s['termsInAttendance']}.sort.last
      end
    end

    def student_academic_levels
      current_term_registrations.collect {|registration| academic_level_description(registration) }
    end

    private

    def student_data
      @student_data ||= HubEdos::V2::Student.new(user_id: @uid).get
    end

    def academic_level_description(registration)
      type_code = registration['academicCareer']['code'] == 'LAW' ? 'EOT' : 'BOT'
      level = registration['academicLevels'].find {|al| al['type']['code'] == type_code }
      level['level']['description']
    end

    def current_term_registrations
      @current_term_registrations ||= begin
        current_term_id = Berkeley::Terms.fetch.current.campus_solutions_id
        if registrations = student_data[:feed]['registrations']
          registrations.select { |r| r['term']['id'] == current_term_id }
        else
          []
        end
      end
    end
  end
end
