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

    def student_academic_level
      type_code = current_registration['academicCareer']['code'] == 'LAW' ? 'EOT' : 'BOT'
      level = current_registration['academicLevels'].find {|al| al['type']['code'] == type_code }
      level['level']['description']
    end

    private

    def student_data
      @student_data ||= HubEdos::V2::Student.new(user_id: @uid).get
    end

    def current_registration
      @current_registration ||= begin
        if registrations = student_data[:feed]['registrations']
          registrations.find { |r| r['term']['id'] == Berkeley::Terms.fetch.current.campus_solutions_id }
        end
      end
    end
  end
end
