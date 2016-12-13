module CampusSolutions
  class CollegeSchedulerUrl < Proxy

    include CampusSolutionsIdRequired
    include EnrollmentCardFeatureFlagged

    def initialize(options = {})
      super(options)
      @term_id = options[:term_id]
      @acad_career = options[:acad_career]
      initialize_mocks if @fake
    end

    def get_college_scheduler_url
      return nil unless is_feature_enabled
      response = self.get
      [:feed, :scheduleplannerssolink, :url].inject(response) { |hash, key| hash[key] if hash }
    end

    def xml_filename
      'college_scheduler_url.xml'
    end

    def url
      "#{@settings.base_url}/UC_SR_COLLEGE_SCHDLR_URL.v1/get?EMPLID=#{@campus_solutions_id}&STRM=#{@term_id}&ACAD_CAREER=#{@acad_career}&INSTITUTION=UCB01&ADVISORID="
    end

  end
end
