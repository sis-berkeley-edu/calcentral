module HubEdos
  module StudentApi
    module V2
      module Student
        class AcademicStatus

          def initialize(data)
            @data = data || {}
          end

          # A Student Plan describes a plan of study (and corresponding program) the student is pursuing
          def student_plans
            ::HubEdos::StudentApi::V2::Student::StudentPlans.new(@data['studentPlans']) if @data['studentPlans']
          end

          def active_student_plans
            student_plans.active
          end

          def completed_student_plans
            student_plans.completed
          end

          # A Student Career describes a high level grouping of academic policy, such as "Undergraduate" or "Law," the student is pursuing
          def student_career
            ::HubEdos::StudentApi::V2::Student::StudentCareer.new(@data['studentCareer'])
          end
        end
      end
    end
  end
end
