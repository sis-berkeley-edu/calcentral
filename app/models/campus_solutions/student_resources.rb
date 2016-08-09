module CampusSolutions
  class StudentResources < Proxy

    include CampusSolutionsIdRequired

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def get
      resource_links = {}
      empl_id = lookup_campus_solutions_id
      link_ids = {
        change_of_academic_plan_add: 'UC_CX_GT_CPPSTACK_ADD',
        change_of_academic_plan_view: 'UC_CX_GT_CPPSTACK_VIEW',
        emergency_loan_form_add: 'UC_CX_GT_FAEMRLAON_ADD',
        emergency_loan_form_view: 'UC_CX_GT_FAEMRLAON_VIEW',
        withdraw_from_semester_add: 'UC_CX_SRWITHDRL_ADD',
        veterans_benefits_add: 'UC_CX_GT_SRVAONCE_ADD'
      }

      link_ids.each do |key, url_id|
        link = CampusSolutions::Link.new.get_url(url_id, { :EMPLID => empl_id })
        if link[:feed][:link]
          resource_links[key.to_s.camelize(:lower).to_sym] = link[:feed][:link]
        end
      end

      {
        statusCode: 200,
        feed: {
          resources: resource_links
        }
      }
    end

    def xml_filename
      'file_is_not_used_in_test.xml'
    end

  end
end
