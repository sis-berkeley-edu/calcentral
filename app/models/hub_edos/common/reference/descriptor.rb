module HubEdos
  module Common
    module Reference
      # maps an abstract or abbreviated code to a set of descriptions
      class Descriptor
        attr_accessor :data

        def initialize(data)
          @data = data || {}
        end

        # a short string used as a placeholder for the associated description	string
        def code
          @data['code']
        end

        # the full description implied by the code
        def description
          @data['description']
        end

        # a longer, more official version of the description
        def formal_description
          @data['formalDescription']
        end

        def as_json(options={})
          {
            code: code,
            description: description,
            formalDescription: formal_description,
          }.compact
        end
      end
    end
  end
end
