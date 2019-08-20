module MyAcademics
  class AcademicLevels < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      {
        academic_levels: student_academic_levels,
      }
    end

    private

    def student_academic_levels
      latest_term_registrations.collect {|registration| academic_level_description(registration) }
    end

    def student_data
      @student_data ||= HubEdos::StudentApi::V2::Registrations.new(user_id: @uid).get
    end

    def student_registrations
      student_data[:feed]['registrations']
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
