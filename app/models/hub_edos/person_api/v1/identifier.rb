module HubEdos
  module PersonApi
    module V1
      class Identifier
        def initialize(data)
          @data = data || {}
        end

        # the kind of identifier, often the name of the system (all lowercase, no whitespace, hyphens separating words)
        def type
          @data['type']
        end

        # the ID code or number itself
        def id
          @data['id']
        end

        # an indicator of whether this identifier should be disclosed to the public
        def disclose
          @data['disclose']
        end

        # the date this identifier came into use
        def from_date
          Date.parse(@data['fromDate']) if @data['fromDate']
        end

        def as_json(options={})
          {
            type: type,
            id: id,
            fromDate: (from_date.present? ? from_date.to_s : nil),
            disclose: disclose
          }
        end
      end
    end
  end
end
