module CampusSolutions
  class StudentResources < Proxy

    include CampusSolutionsIdRequired

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
        { feed_key: :emergency_loan_form_add, cs_link_key: 'UC_CX_GT_FAEMRLAON_ADD' },
        { feed_key: :emergency_loan_form_view, cs_link_key: 'UC_CX_GT_FAEMRLAON_VIEW' },
        { feed_key: :higher_degrees_committee_form, cs_link_key: 'UC_CX_GT_AAQEAPPLIC_ADD' },
        { feed_key: :special_enrollment_petition, cs_link_key: 'UC_CX_GT_SRSEP_ADD' },
        { feed_key: :submit_degree_candidacy_form, cs_link_key: 'UC_CX_GT_SRDCR_ADD' },
        { feed_key: :update_pending_forms, cs_link_key: 'UC_CX_GT_STUDENT_UPDATE' },
        { feed_key: :veterans_benefits_add, cs_link_key: 'UC_CX_GT_SRVAONCE_ADD' },
        { feed_key: :view_submitted_forms, cs_link_key: 'UC_CX_GT_STUDENT_VIEW'},
        { feed_key: :withdraw_from_semester_add, cs_link_key: 'UC_CX_SRWITHDRL_ADD' }
      ]

      campus_solutions_link_settings.each do |setting|
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

    def xml_filename
      'file_is_not_used_in_test.xml'
    end

    def fetch_link(link_key, placeholders = {})
      CampusSolutions::Link.new.get_url(link_key, placeholders).try(:[], :link)
    end

  end
end
