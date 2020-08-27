module HubEdos
  module StudentApi
    module V2
      module AcademicPolicy
        # An Academic Plan is an area of study within an academic program, such as a major, minor, or specialization
        class AcademicPlan
          def initialize(data)
            @data = data || {}
          end

          # a simple descriptor representing the plan
          def plan
            ::HubEdos::Common::Reference::Descriptor.new(@data['plan']) if @data['plan']
          end

          #	a simple descriptor categorizing the plan as major, minor, etc.
          def type
            ::HubEdos::Common::Reference::Descriptor.new(@data['type']) if @data['type']
          end

          # the Classification of Instructional Programs taxonomic code as determined by the U.S. Department of Education
          def cip_code
            @data['cipCode']
          end

          # the Higher Education General Information Survey taxonomic code used by the National Center for Education Statistics
          def hegis_code
            @data['hegisCode']
          end

          # certification of the successful completion of an academic plan
          def target_degree
            HubEdos::StudentApi::V2::AcademicPolicy::AcademicDegree.new(@data['targetDegree']) if @data['targetDegree']
          end

          # an administraive organization (e.g., a department or college) that controls a group of academic policy
          def owned_by
            HubEdos::StudentApi::V2::AcademicPolicy::AdministrativeOwners.new(@data['ownedBy']) if @data['ownedBy']
          end

          # describes a grouping of policy that tends to deal with overall curricular issues
          def academic_program
            HubEdos::StudentApi::V2::AcademicPolicy::AcademicProgram.new(@data['academicProgram']) if @data['academicProgram']
          end

          def as_json(options={})
            {
              plan: plan,
              type: type,
              cipCode: cip_code,
              hegisCode: hegis_code,
              targetDegree: target_degree,
              ownedBy: owned_by,
              academicProgram: academic_program,
            }.compact
          end
        end
      end
    end
  end
end
