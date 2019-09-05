module HubEdos
  module StudentApi
    module V2
      class AcademicStatuses < ::HubEdos::StudentApi::V2::Proxy
        def url
          "#{@settings.base_url}/v2/students/#{@campus_solutions_id}?inc-acad=true&inc-completed-programs=false&inc-inactive-programs=false"
        end

        def json_filename
          'hub_v2_student_academic_status.json'
        end

        def whitelist_fields
          ['academicStatuses', 'holds', 'awardHonors', 'degrees']
        end
      end
    end
  end
end
