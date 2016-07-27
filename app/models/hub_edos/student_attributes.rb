module HubEdos
  class StudentAttributes < Student

    include Cache::UserCacheExpiry

    def initialize(options = {})
      super(options)
    end

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/student-attributes"
    end

    def json_filename
      'hub_student_attributes.json'
    end

    def include_fields
      %w(studentAttributes)
    end

    def get
      return {} unless is_feature_enabled
      response = self.class.smart_fetch_from_cache(id: instance_key) do
        get_internal
      end
      decorate_internal_response response
    end

  end
end
