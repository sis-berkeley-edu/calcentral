module CampusSolutions
  class AdvisingAcademicPlan < Proxy

    include CampusSolutionsIdRequired

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def build_feed(response)
      (response && response['UC_AA_ACAD_PLANNER']) || {}
    end

    def xml_filename
      'advising_academic_plan.xml'
    end

    def url
      "#{@settings.base_url}/UC_AA_ACAD_PLANNER.v1/get?EMPLID=#{@campus_solutions_id}"
    end

  end
end
