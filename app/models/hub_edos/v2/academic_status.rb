module HubEdos
  module V2
    class AcademicStatus < Student
      def url
        "#{@settings.base_url}/v2/students/#{@campus_solutions_id}?inc-acad=true"
      end

      def json_filename
        'hub_v2_academic_status.json'
      end
    end
  end
end
