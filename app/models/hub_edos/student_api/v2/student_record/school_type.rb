module HubEdos
  module StudentApi
    module V2
      module StudentRecord
        # A School Type describes the kind of educational institution.
        class SchoolType
          def initialize(data)
            @data = data
          end

          # a short string used to indicate the school type
          def code
            @data['code']
          end

          # the full description of the type, such as "California Community College," or "US High School,"
          def description
            @data['description']
          end

          # a coarse grouping of school types, such as "Two Year," "Four Year," or "Unknown"
          def category
            @data['category']
          end

        end
      end
    end
  end
end
