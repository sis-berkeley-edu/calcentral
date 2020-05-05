module User
  module Academics
    module DegreeProgress
      module Graduate
        class StudentLinks
          attr_reader :user

          APR_LINK_ID_LAW = 'UC_CX_APR_RPT_GRD_STDNT_LAW'
          APR_LINK_ID_GRAD = 'UC_CX_APR_RPT_GRD_STDNT'

          def initialize(user)
            @user = user
          end

          def links
            links = {}
            links[:academic_progress_report_law] = academic_progress_report_law_link if apr_law_student?
            links[:academic_progress_report_grad] = academic_progress_report_grad_link if apr_grad_student?
            links
          end

          def academic_progress_report_law_link
            LinkFetcher.fetch_link(APR_LINK_ID_LAW, { :EMPLID => user.campus_solutions_id })
          end

          def academic_progress_report_grad_link
            LinkFetcher.fetch_link(APR_LINK_ID_GRAD, { :EMPLID => user.campus_solutions_id })
          end

          def apr_law_student?
            current_user_roles.to_set.intersect? Set[
              :doctorScienceLaw,
              :jurisSocialPolicyMasters,
              :jurisSocialPolicyPhC,
              :jurisSocialPolicyPhD,
              :lawJdCdp,
              :masterOfLawsLlm
            ]
          end

          def apr_grad_student?
            !get_incomplete_programs_roles.empty?
          end

          def get_incomplete_programs_roles
            grad_statuses = MyAcademics::MyAcademicStatus.statuses_by_career_role(user.uid, ['grad'])
            return [] if grad_statuses.blank?

            plans = incomplete_plans_from_statuses(grad_statuses)
            return [] if plans.blank?

            plans.map do |plan|
              program = plan.try(:[], 'academicPlan').try(:[], 'academicProgram').try(:[], 'program')
              program.try(:[], 'code')
            end.uniq.compact
          end

          def incomplete_plans_from_statuses(statuses)
            [].tap do |plans|
              statuses.try(:each) do |status|
                status.try(:[], 'studentPlans').try(:each) do |plan|
                  if incomplete_plan? plan
                    plans.push(plan)
                  end
                end
              end
            end
          end

          def incomplete_plan?(plan)
            plan.try(:[], 'statusInPlan').try(:[], 'status').try(:[], 'code') != 'CM'
          end

          def current_user_roles
            @current_user_roles ||= User::Academics::Roles.new(user).current_user_roles
          end
        end
      end
    end
  end
end
