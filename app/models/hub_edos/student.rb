module HubEdos
  class Student
    def initialize(uid)
      @uid = uid
    end

    def max_terms_in_attendance
      if student_academic_statuses
        return student_academic_statuses.collect {|s| s['termsInAttendance']}.sort.last
      end
    end

    def student_academic_levels
      latest_term_registrations.collect {|registration| academic_level_description(registration) }
    end

    private

    def student_data
      @student_data ||= HubEdos::StudentApi::V2::Student.new(user_id: @uid).get
    end

    def student_registrations
      student_data[:feed]['registrations']
    end

    def student_academic_statuses
      student_data[:feed]['academicStatuses']
    end

    def academic_level_description(registration)
      type_code = registration['academicCareer']['code'] == 'LAW' ? 'EOT' : 'BOT'
      level = registration['academicLevels'].find {|al| al['type']['code'] == type_code }
      level['level']['description']
    end

    def latest_term_registrations
      @latest_term_registrations ||= begin
        if student_registrations
          highest_term_id = highest_registrations_term_id
          student_registrations.select { |reg| reg['term']['id'] == highest_term_id }
        else
          []
        end
      end
    end

    def highest_registrations_term_id
      student_registrations.collect {|reg| reg['term'].try(:[], 'id') }.sort.last
    end
  end
end
