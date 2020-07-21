module HubEdos
  module StudentApi
    module V2
      module AcademicPolicy
        # An Academic Degree is certification of the successful completion of an academic plan.
        class AcademicDegree

          def initialize(data={})
            @data = data
          end

          # a simple descriptor representing the kind of degree, such as Bachelor of Science, etc.
          def type
            ::HubEdos::Common::Reference::Descriptor.new(@data['type']) if @data['type']
          end

          # the official abbreviation for the degree, such as BA or PhD, etc.
          def abbreviation
            @data['abbreviation']
          end

        end
      end
    end
  end
end
