module HubEdos
  module V1
    class AcademicStatus < V1::Student
      def url
        "#{@settings.base_url}/v1/students/#{@campus_solutions_id}/academic-status"
      end

      def json_filename
        'hub_academic_status.json'
      end

      def whitelist_fields
        %w(academicStatuses awardHonors degrees holds)
      end
    end
  end
end
