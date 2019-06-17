module HubEdos
  module StudentApi
    module V2
      class WorkExperiences < ::HubEdos::StudentApi::V2::Proxy
        include HubEdos::CachedProxy
        include Cache::UserCacheExpiry

        def url
          "#{@settings.base_url}/v2/students/#{@campus_solutions_id}?inc-work=true"
        end

        def json_filename
          'hub_v2_student_work_experiences.json'
        end

        def whitelist_fields
          ['workExperiences']
        end
      end
    end
  end
end
