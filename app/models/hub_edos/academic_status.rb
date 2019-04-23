module HubEdos
  class AcademicStatus < Student

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/academic-status"
    end

    def json_filename
      'hub_academic_status.json'
    end

    def whitelist_fields
      %w(academicStatuses awardHonors degrees holds)
    end
  end
end
