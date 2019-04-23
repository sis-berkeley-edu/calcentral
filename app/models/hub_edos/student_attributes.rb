module HubEdos
  class StudentAttributes < Student
    include HubEdos::CachedProxy
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

    def whitelist_fields
      %w(studentAttributes)
    end

  end
end
