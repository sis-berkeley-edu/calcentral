module User
  module Academics
    module DegreeProgress
      module Graduate
        class StudentLinks
          attr_reader :user

          APR_LINK_ID_HAAS = 'UC_CX_APR_RPT_GRD_STDNT_HAAS'
          APR_LINK_ID_LAW = 'UC_CX_APR_RPT_GRD_STDNT_LAW'
          APR_LINK_ID_GRAD = 'UC_CX_APR_RPT_GRD_STDNT'

          def initialize(user)
            @user = user
          end

          def links
            links = {}
            links[:academic_progress_report_haas] = academic_progress_report_haas_link if apr_haas_student?
            links[:academic_progress_report_law] = academic_progress_report_law_link if apr_law_student?
            links[:academic_progress_report_grad] = academic_progress_report_grad_link if apr_non_haas_grad_student?
            links
          end

          def academic_progress_report_haas_link
            LinkFetcher.fetch_link(APR_LINK_ID_HAAS, { :EMPLID => user.campus_solutions_id })
          end

          def academic_progress_report_law_link
            LinkFetcher.fetch_link(APR_LINK_ID_LAW, { :EMPLID => user.campus_solutions_id })
          end

          def academic_progress_report_grad_link
            LinkFetcher.fetch_link(APR_LINK_ID_GRAD, { :EMPLID => user.campus_solutions_id })
          end

          def apr_haas_student?
            current_user_roles.to_set.intersect? Set[
              :haasBusinessAdminMasters,
              :haasBusinessAdminPhD
            ]
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

          def apr_non_haas_grad_student?
            is_grad_student = current_user_roles.to_set.intersect? Set[:grad]
            is_haas_student = current_user_roles.to_set.intersect? Set[
              :haasBusinessAdminMasters,
              :haasBusinessAdminPhD,
              :haasFullTimeMba,
              :haasEveningWeekendMba,
              :haasExecMba,
              :haasMastersFinEng,
              :haasMbaPublicHealth,
              :haasMbaJurisDoctor
            ]
            is_grad_student && !is_haas_student
          end

          def current_user_roles
            @current_user_roles ||= User::Academics::Roles.new(user).current_user_roles
          end
        end
      end
    end
  end
end
