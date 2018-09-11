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
        { feed_key: :withdraw_from_semester_add, cs_link_key: 'UC_CX_SRWITHDRL_ADD' }
      ]

      filtered_link_settings = filter_links_by_roles campus_solutions_link_settings

      filtered_link_settings.each do |setting|
        link = fetch_link(setting[:cs_link_key])
        cs_links[setting[:feed_key]] = link unless link.blank?
      end

      {
        statusCode: 200,
        feed: {
          resources: HashConverter.camelize(cs_links)
        }
      }
    end

    def filter_links_by_roles(link_settings)
      user_attributes = User::AggregatedAttributes.new(@uid).get_feed
      roles = user_attributes.try(:[], :roles)
      ucbx_only_links = [:disabled_student_services, :register_to_vote_ca, :register_to_vote_non_ca]

      if is_ucbx_only? roles
        link_settings.select { |link| ucbx_only_links.include? link[:feed_key] }
      else
        link_settings
      end
    end

    def is_ucbx_only?(roles)
      roles[:concurrentEnrollmentStudent] && !(roles[:undergrad] || roles[:graduate] || roles[:law])
    end

    def xml_filename
      'file_is_not_used_in_test.xml'
    end
  end
end
