module HubEdos
  module V1
    class Demographics < Student
      include HubEdos::CachedProxy
      include Cache::UserCacheExpiry

      def url
        "#{@settings.base_url}/v1/students/#{@campus_solutions_id}/demographic"
      end

      def json_filename
        'hub_demographics.json'
      end

      def whitelist_fields
        %w(ethnicities languages usaCountry foreignCountries birth residency)
      end

    end
  end
end
