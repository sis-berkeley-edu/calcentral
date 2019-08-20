module HubEdos
  module StudentApi
    module V2
      class Registrations < ::HubEdos::StudentApi::V2::Proxy
        def url
          "#{@settings.base_url}/v2/students/#{@campus_solutions_id}?inc-regs=true"
        end

        def json_filename
          'hub_v2_student_registrations.json'
        end

        def whitelist_fields
          ['registrations']
        end
      end
    end
  end
end
