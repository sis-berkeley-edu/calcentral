module HubEdos
  module PersonApi
    module V1
      class Names
        attr_reader :data

        def initialize(data = [])
          @data = data
        end

        def all
          @all ||= data.collect do |name_data|
            ::HubEdos::PersonApi::V1::Name.new(name_data)
          end
        end
      end
    end
  end
end
