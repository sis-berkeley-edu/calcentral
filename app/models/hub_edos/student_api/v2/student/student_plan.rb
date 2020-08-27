module HubEdos
  module StudentApi
    module V2
      module Student
        # A Student Plan describes a plan of study (and corresponding program) the student is pursuing
        class StudentPlan
          def initialize(data)
            @data = data || {}
          end

          # a component representing the plan, such as Anthropology BA, etc.
          def academic_plan
            ::HubEdos::StudentApi::V2::AcademicPolicy::AcademicPlan.new(@data['academicPlan']) if @data['academicPlan']
          end

          # a list of components representing concentrations or emphases within the plan, such as Neurobiology, etc
          def academic_sub_plans
            if @data['academicSubPlans']
              @academic_sub_plans ||= begin
                sub_plans = @data['academicSubPlans'] || []
                sub_plans.collect do |academic_sub_plan|
                  ::HubEdos::StudentApi::V2::AcademicPolicy::AcademicSubPlan.new(academic_sub_plan)
                end
              end
            end
          end

          # describes the student's current status within the academic plan and program
          def status_in_plan
            if @data['statusInPlan']
              ::HubEdos::StudentApi::V2::Student::StatusInPlan.new(@data['statusInPlan'])
            end
          end

          def active?
            !!status_in_plan && status_in_plan.status_code == 'AC'
          end

          def completed?
            !!status_in_plan && status_in_plan.status_code == 'CM'
          end

          # an indicator of whether this is the main or "home" plan for the student
          def primary
            @data['primary']
          end

          # a component that describes the term during which the student is expected to complete the plan
          def expected_graduation_term
            if @data['expectedGraduationTerm']
              ::HubEdos::StudentApi::V2::Term::Term.new(@data['expectedGraduationTerm'])
            end
          end

          def expected_graduation_term_id
            expected_graduation_term.id if expected_graduation_term
          end

          # a component that describes the student's state within the graduation process
          def degree_checkout_status
            if @data['degreeCheckoutStatus']
              ::HubEdos::Common::Reference::Descriptor.new(@data['degreeCheckoutStatus'])
            end
          end

          def degree_checkout_status_code
            degree_checkout_status && degree_checkout_status.code
          end

          def degree_eligible?
            degree_checkout_status_code == 'EG'
          end

          def degree_awarded?
            degree_checkout_status_code == 'AW'
          end

          # the date on which the plan was associated with the student
          def from_date
            @from_date ||= begin
              Date.parse(@data['fromDate']) if @data['fromDate']
            end
          end

          # the date on which the plan was no longer associated with the student
          def to_date
            @to_date ||= begin
              Date.parse(@data['toDate']) if @data['toDate']
            end
          end

          def as_json(options={})
            {
              academicPlan: academic_plan,
              academicSubPlans: academic_sub_plans,
              statusInPlan: status_in_plan,
              primary: primary,
              expectedGraduationTerm: expected_graduation_term,
              degreeCheckoutStatus: degree_checkout_status,
              fromDate: from_date,
              toDate: to_date,
            }.compact
          end

        end
      end
    end
  end
end
