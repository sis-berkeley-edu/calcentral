module HubEdos
  module V1
    # For reasons unknown, Registrations seems to be the one HubEdos payload which doesn't include a "students" wrapper,
    # which is why this class doesn't inherit from HubEdos::V1::Student.
    class Registrations < Proxy

      def url
        "#{@settings.base_url}/v1/students/#{@campus_solutions_id}/registrations"
      end

      def json_filename
        'hub_registrations.json'
      end

      def wrapper_keys
        %w(apiResponse response any)
      end
    end
  end
end
