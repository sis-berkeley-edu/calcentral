module HubEdos
  module StudentApi
    module V2
      module AcademicPolicy
        class AdministrativeOwners
          def initialize(data=[])
            @data = data
          end

          def all
            @data.collect do |administrative_owner|
              HubEdos::StudentApi::V2::AcademicPolicy::AdministrativeOwner.new(administrative_owner)
            end
          end
        end
      end
    end
  end
end
