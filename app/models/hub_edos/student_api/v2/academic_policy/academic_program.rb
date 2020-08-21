module HubEdos
  module StudentApi
    module V2
      module AcademicPolicy
        # An Academic Program describes a grouping of policy that tends to deal with overall curricular issues.
        # Examples include "Undergrad Letters & Science" and "Graduate Professional Programs."
        # (It doesn't imply campus administrative organization, but instead the grouping of acadmic policy that applies to a student.)
        class AcademicProgram

          def initialize(data={})
            @data = data
          end

          # a simple descriptor representing the program
          def program
            ::HubEdos::Common::Reference::Descriptor.new(@data['program']) if @data['program']
          end

          #	a simple descriptor representing the next highest academic grouping within the UC Berkeley (i.e., the Colleges and Schools)
          def academic_group
            ::HubEdos::Common::Reference::Descriptor.new(@data['academicGroup']) if @data['academicGroup']
          end

          # an administraive organization (e.g., a department or college) that controls a group of academic policy
          def owned_by
            HubEdos::StudentApi::V2::AcademicPolicy::AdministrativeOwners.new(@data['ownedBy'])
          end

          # a simple descriptor representing the highest level grouping of academic policy within UC Berkeley.
          # Examples include "Undergraduate," "Graduate," and "Law."
          def academic_career
            ::HubEdos::Common::Reference::Descriptor.new(@data['academicCareer']) if @data['academicCareer']
          end

        end
      end
    end
  end
end
