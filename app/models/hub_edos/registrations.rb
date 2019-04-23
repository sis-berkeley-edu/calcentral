module HubEdos
  # For reasons unknown, Registrations seems to be the one HubEdos payload which doesn't include a "students" wrapper,
  # which is why this class doesn't inherit from HubEdos::Student.
  class Registrations < Proxy

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/registrations"
    end

    def json_filename
      'hub_registrations.json'
    end

  end
end
