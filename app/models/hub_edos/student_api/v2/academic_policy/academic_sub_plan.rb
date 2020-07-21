module HubEdos
  module StudentApi
    module V2
      module AcademicPolicy
        # An Academic Subplan is a concentration within an academic plan.
        class AcademicSubPlan
          def initialize(data={})
            @data = data
          end

          # a simple descriptor representing the subplan
          def sub_plan
            ::HubEdos::Common::Reference::Descriptor.new(@data['subPlan']) if @data['subPlan']
          end

          # the Classification of Instructional Programs taxonomic code as determined by the U.S. Department of Education
          def cip_code
            @data['cipCode']
          end

          # the Higher Education General Information Survey taxonomic code used by the National Center for Education Statistics
          def hegis_code
            @data['hegisCode']
          end

          # An Academic Plan is an area of study within an academic program, such as a major, minor, or specialization
          def academic_plan
            ::HubEdos::StudentApi::V2::AcademicPolicy::AcademicPlan.new(@data['academicPlan']) if @data['academicPlan']
          end
        end
      end
    end
  end
end
