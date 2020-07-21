module HubEdos
  module StudentApi
    module V2
      module AcademicPolicy
        # An Academic Subplan is a concentration within an academic plan.
        class AcademicSubPlans
          def initialize(data={})
            @data = data
          end

          def all
            @data.collect do |academic_sub_plan|
              ::HubEdos::StudentApi::V2::AcademicPolicy::AcademicSubPlan.new(academic_sub_plan)
            end
          end
        end
      end
    end
  end
end
