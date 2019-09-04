module HubEdos
  module PersonApi
    module V1
      class SisPerson < ::HubEdos::Proxy
        include HubEdos::CachedProxy
        include Cache::UserCacheExpiry

        def settings
          Settings.hub_person_proxy
        end

        def url
          # Contact information not currently needed and thus excluded ('&inc-cntc=true')
          "#{@settings.base_url}/v1/sis-person/#{@campus_solutions_id}"
        end

        def json_filename
          'hub_v1_person.json'
        end

        def wrapper_keys
          %w(apiResponse response person)
        end
      end
    end
  end
end
