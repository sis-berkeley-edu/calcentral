module HubEdos
  module StudentApi
    module V2
      class StudentAttributes < ::HubEdos::StudentApi::V2::Proxy
        include HubEdos::CachedProxy
        include Cache::UserCacheExpiry

        def url
          "#{@settings.base_url}/v2/students/#{@campus_solutions_id}?inc-attr=true"
        end

        def json_filename
          'hub_v2_student_attributes.json'
        end

        def whitelist_fields
          ['studentAttributes', 'confidential']
        end
      end
    end
  end
end
