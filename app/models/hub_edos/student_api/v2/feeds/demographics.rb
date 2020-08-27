module HubEdos
  module StudentApi
    module V2
      module Feeds
        class Demographics < ::HubEdos::StudentApi::V2::Feeds::Proxy
          include HubEdos::CachedProxy
          include Cache::UserCacheExpiry

          def url
            "#{@settings.base_url}/v2/students/#{@campus_solutions_id}?inc-dmgr=true"
          end

          def json_filename
            'hub_v2_student_demographics.json'
          end

          def whitelist_fields
            ['ethnicities', 'usaCountry', 'residency']
          end
        end
      end
    end
  end
end
