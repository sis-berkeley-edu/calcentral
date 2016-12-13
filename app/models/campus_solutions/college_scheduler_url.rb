module CampusSolutions
  class CollegeSchedulerUrl < Proxy

    include CampusSolutionsIdRequired
    include EnrollmentCardFeatureFlagged

    def initialize(options = {})
      super(options)
      @term_id = options[:term_id]
      @acad_career = options[:acad_career]
      @student_uid = options[:student_user_id]
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
      if @student_uid.present? && student_campus_solutions_id = CalnetCrosswalk::ByUid.new(user_id: @student_uid).lookup_campus_solutions_id
        emplid = student_campus_solutions_id
        advisor_id = @campus_solutions_id
      else
        emplid = @campus_solutions_id
        advisor_id = ''
      end
      "#{@settings.base_url}/UC_SR_COLLEGE_SCHDLR_URL.v1/get?EMPLID=#{emplid}&STRM=#{@term_id}&ACAD_CAREER=#{@acad_career}&INSTITUTION=UCB01&ADVISORID=#{advisor_id}"
    end

  end
end
