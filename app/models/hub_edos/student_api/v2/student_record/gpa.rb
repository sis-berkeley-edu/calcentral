module HubEdos
  module StudentApi
    module V2
      module StudentRecord
        # A GPA is an average number of grade points earned per unit taken for some group of academic credit
        class Gpa
          def initialize(data)
            @data = data || {}
          end

          # a short descriptor representing the kind or use of the GPA, such as cummulative, term, etc.
          def type
            @data['type']
          end

          # the numeric grade point average itself
          def average
            @data['average']
          end

          # the maximum value based on the system used to calculate the GPA, typically 4.000
          def scale
            @data['scale']
          end

          # the system, organization, or person providing the GPA	string
          def source
            @data['source']
          end
        end
      end
    end
  end
end
