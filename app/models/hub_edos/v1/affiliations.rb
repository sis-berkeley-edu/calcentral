module HubEdos
  module V1
    class Affiliations < Student
      include HubEdos::CachedProxy
      include Cache::UserCacheExpiry

      def url
        "#{@settings.base_url}/v1/students/#{@campus_solutions_id}/affiliation"
      end

      def json_filename
        'hub_affiliations.json'
      end

      def whitelist_fields
        %w(affiliations identifiers confidential)
      end

    end
  end
end
