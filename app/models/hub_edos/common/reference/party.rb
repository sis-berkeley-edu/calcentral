module HubEdos
  module Common
    module Reference
      # A Party maps a unique ID to the name of a person or organization
      class Party

        def initialize(data)
          @data = data || {}
        end

        # the ID code or number associated with the person or organization
        def id
          @data['id']
        end

    	  # the full name of the person or organization
        def name
          @data['name']
        end

        def as_json(options={})
          {
            id: id,
            name: name,
          }.compact
        end
      end
    end
  end
end
