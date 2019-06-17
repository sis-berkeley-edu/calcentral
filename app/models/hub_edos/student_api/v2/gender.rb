module HubEdos
  module StudentApi
    module V2
      class Gender < ::HubEdos::StudentApi::V2::Proxy
        include HubEdos::CachedProxy
        include Cache::UserCacheExpiry

        def url
          "#{@settings.base_url}/v2/students/#{@campus_solutions_id}?inc-gndr=true"
        end

        def json_filename
          'hub_v2_student_gender.json'
        end

        def whitelist_fields
          ['gender']
        end
      end
    end
  end
end
