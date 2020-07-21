module HubEdos
  module StudentApi
    module V2
      module Student
        # Interface for a collection of StudentPlan objects
        class StudentPlans
          def initialize(data)
            @data = data || []
          end

          def all
            @data.collect do |student_plan|
              ::HubEdos::StudentApi::V2::Student::StudentPlan.new(student_plan)
            end
          end

          def active
            all.select { |student_plan| student_plan.active? }
          end

          def completed
            all.select { |student_plan| student_plan.completed? }
          end
        end
      end
    end
  end
end
