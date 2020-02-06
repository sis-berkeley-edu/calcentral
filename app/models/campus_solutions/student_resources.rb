module CampusSolutions
  class StudentResources < Proxy

    include CampusSolutionsIdRequired
    include LinkFetcher

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def get
      empl_id = lookup_campus_solutions_id
      return {} if empl_id.blank?

      cs_links = {}

      campus_solutions_link_settings = [
        { feed_key: :grad_change_of_academic_plan_add, cs_link_key: 'UC_CX_GT_GRADCPP_ADD' },
        { feed_key: :change_of_academic_plan_add, cs_link_key: 'UC_CX_GT_CPPSTACK_ADD' },
        { feed_key: :change_of_academic_plan_view, cs_link_key: 'UC_CX_GT_CPPSTACK_VIEW' },
        { feed_key: :disabled_student_services, cs_link_key: 'UC_CX_DSP_STDNT_SVCS' },
        { feed_key: :disabled_students_program_services, cs_link_key: 'UC_CX_DSP_PGM_SVCS' },
        { feed_key: :emergency_loan_form_add, cs_link_key: 'UC_CX_GT_FAEMRLAON_ADD' },
        { feed_key: :emergency_loan_form_view, cs_link_key: 'UC_CX_GT_FAEMRLAON_VIEW' },
        { feed_key: :higher_degrees_committee_form, cs_link_key: 'UC_CX_GT_AAQEAPPLIC_ADD' },
        { feed_key: :register_to_vote_ca, cs_link_key: 'UC_SR_VOTER_REG_CA' },
        { feed_key: :register_to_vote_non_ca, cs_link_key: 'UC_SR_VOTER_REG_NON_CA' },
        { feed_key: :scarab_login, cs_link_key: 'UC_CX_DSP_SCARAB_LOGIN' },
        { feed_key: :special_enrollment_petition, cs_link_key: 'UC_CX_GT_SRSEP_ADD' },
        { feed_key: :submit_degree_candidacy_form, cs_link_key: 'UC_CX_GT_SRDCR_ADD' },
        { feed_key: :update_pending_forms, cs_link_key: 'UC_CX_GT_STUDENT_UPDATE' },
        { feed_key: :veterans_benefits_add, cs_link_key: 'UC_CX_GT_SRVAONCE_ADD' },
        { feed_key: :view_submitted_forms, cs_link_key: 'UC_CX_GT_STUDENT_VIEW'},
        { feed_key: :withdraw_from_semester_add, cs_link_key: 'UC_CX_SRWITHDRL_ADD' },
        { feed_key: :dissertation_signature, cs_link_key: 'UC_CX_GT_GRADDISSIG_ADD' },
        { feed_key: :expected_grad_term_add, cs_link_key: 'UC_CX_GT_GRADEGT_ADD' }
      ]
      link_configuration = [
        {
          section: 'Submit a Form',
          links: [:change_of_academic_plan_add, :emergency_loan_form_add, :veterans_benefits_add, :withdraw_from_semester_add,
                  :higher_degrees_committee_form, :special_enrollment_petition, :submit_degree_candidacy_form,
                  :grad_change_of_academic_plan_add, :dissertation_signature, :expected_grad_term_add],
        },
        {
          section: 'Manage your Forms',
          links: [:view_submitted_forms, :update_pending_forms, :emergency_loan_form_view],
        },
        {
          section: 'Campus Services',
          links: [:disabled_students_program_services, :scarab_login, :disabled_student_services],
        },
        {
          section: 'Co-Curricular',
          links: [:register_to_vote_ca, :register_to_vote_non_ca],
        }
      ]

      filtered_link_settings = filter_link_settings campus_solutions_link_settings

      filtered_link_settings.each do |setting|
        link = fetch_link(setting[:cs_link_key])
        cs_links[setting[:feed_key]] = link unless link.blank?
      end

      filtered_link_configuration = filter_link_configuration link_configuration
      transformed_link_configuration = transform_link_configuration(cs_links, filtered_link_configuration)

      {
        statusCode: 200,
        feed: {
          resources: transformed_link_configuration
        }
      }
    end

    def filter_link_configuration(link_configuration)
      link_configuration.delete_if do |config|
        case config[:section]
        when "Submit a Form", "Manage your Forms"
          true unless is_general_student?
        else
          false
        end
      end
    end

    def filter_link_settings(link_settings)
      ucbx_only_links = [:disabled_student_services, :register_to_vote_ca, :register_to_vote_non_ca]

      if is_ucbx_only?
        link_settings.select { |link| ucbx_only_links.include? link[:feed_key] }
      else
        filter_role_based_link_settings link_settings
      end
    end

    def filter_role_based_link_settings(link_settings)
      link_settings.delete_if do |link|
        case link[:feed_key]
        when :change_of_academic_plan_add
          true unless (!is_non_degree_seeking_summer_visitor? && roles[:undergrad]) || (roles[:graduate] || roles[:law])
        when :emergency_loan_form_add, :emergency_loan_form_view
          true unless !is_non_degree_seeking_summer_visitor?
        when :withdraw_from_semester_add
          true unless !roles[:law]
        when :higher_degrees_committee_form, :special_enrollment_petition
          true unless ((roles[:graduate] || roles[:law]) && !(is_jd_llm_only? || is_law_visiting?))
        when :submit_degree_candidacy_form
          true unless (roles[:graduate] || current_academic_roles["lawJspJsd"])
        when :view_submitted_forms, :update_pending_forms
          true unless !(is_jd_llm_only? || is_law_visiting?)
        when :disabled_students_program_services, :scarab_login
          true unless is_general_student?
        when :disabled_student_services
          true unless roles[:concurrentEnrollmentStudent]
        when :grad_change_of_academic_plan_add
          true unless roles[:graduate]
        when :dissertation_signature, :expected_grad_term_add
          true unless (roles[:graduate] || roles[:law])
        else
          false
        end
      end
    end

    def transform_link_configuration(cs_links, link_configuration)
      link_configuration.each do |config|
        config[:links].map! do |link|
          cs_links[link] ? cs_links[link] : nil
        end.compact!
      end
    end

    def roles
      return @roles if defined? @roles
      @roles ||= begin
        user_attributes = User::AggregatedAttributes.new(@uid).get_feed
        user_attributes.try(:[], :roles)
      end
    end

    def academic_roles
      @academic_roles ||= MyAcademics::MyAcademicRoles.new(@uid).get_feed
    end

    def current_academic_roles
      @current_academic_roles ||= academic_roles.try(:[], :current)
    end

    def historical_academic_roles
      @historical_academic_roles ||= academic_roles.try(:[], :historical)
    end

    def is_ucbx_only?
      roles[:concurrentEnrollmentStudent] && !(roles[:undergrad] || roles[:graduate] || roles[:law])
    end

    def is_general_student?
      roles[:law] || roles[:graduate] || roles[:undergrad]
    end

    def is_jd_llm_only?
      (current_academic_roles["lawJdLlm"] || current_academic_roles["lawJdCdp"]) && !current_academic_roles["lawJspJsd"] && !current_academic_roles["grad"]
    end

    def is_law_visiting?
      current_academic_roles["lawVisiting"] && !current_academic_roles["grad"]
    end

    def is_non_degree_seeking_summer_visitor?
      historical_academic_roles["summerVisitor"] && !historical_academic_roles["degreeSeeking"]
    end

    def xml_filename
      'file_is_not_used_in_test.xml'
    end
  end
end
