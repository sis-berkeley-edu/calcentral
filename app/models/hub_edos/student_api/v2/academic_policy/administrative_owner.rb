module HubEdos
  module StudentApi
    module V2
      module AcademicPolicy
        # A Administrative Owner is an administraive organization (e.g., a department or college) that controls a group of academic policy.
        class AdministrativeOwner

          def initialize(data={})
            @data = data
          end

          # a simple descriptor representing the owning organization
          def organization
            ::HubEdos::Common::Reference::Descriptor.new(@data['organization']) if @data['organization']
          end

          def percentage
            @data['percentage']
          end
        end
      end
    end
  end
end
