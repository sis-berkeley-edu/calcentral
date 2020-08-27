module HubEdos
  module PersonApi
    module V1
      class Identifiers
        attr_reader :data

        def initialize(data = [])
          @data = data
        end

        def all
          @all ||= data.collect do |identifier_data|
            ::HubEdos::PersonApi::V1::Identifier.new(identifier_data)
          end
        end
      end
    end
  end
end
