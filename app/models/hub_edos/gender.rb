module HubEdos
  class Gender < Student
    include HubEdos::CachedProxy
    include Cache::UserCacheExpiry

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/gender"
    end

    def json_filename
      'hub_gender.json'
    end

    def whitelist_fields
      %w(gender)
    end

  end
end
