module HubEdos
  class WorkExperience < Student
    include HubEdos::CachedProxy
    include Cache::UserCacheExpiry

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/work-experiences"
    end

    def json_filename
      'hub_work_experience.json'
    end

    def whitelist_fields
      %w(workExperiences)
    end

    def build_feed(response)
      student = super(response)['student']
      if student['workExperiences'].present?
        {
          'workExperiences' => student['workExperiences']['workExperiences']
        }
      else
        {}
      end
    end

  end
end
