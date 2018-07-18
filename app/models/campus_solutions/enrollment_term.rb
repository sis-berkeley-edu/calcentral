module CampusSolutions
  class EnrollmentTerm < Proxy

    include CampusSolutionsIdRequired
    include DatedFeed
    include EnrollmentCardFeatureFlagged

    def initialize(options = {})
      super options
      @term_id = options[:term_id]
      initialize_mocks if @fake
    end

    def build_feed(response)
      return {} unless response && (enrollment_term = response['UC_SR_CLASS_ENROLLMENT'])

      # Though its name is in the singular, ENROLLMENT_PERIOD is an array containing multiple periods.
      enrollment_term['ENROLLMENT_PERIOD'].each do |period|
        format_cs_datetime(period, '%Y-%m-%dT%H:%M:%S')
      end
      # Clean up empty []
      enrollment_term['ENROLLED_CLASSES'].each do |cls|
        cls['WHEN'] = '' if cls['WHEN'] == []
      end
      if enrollment_term['SCHEDULE_OF_CLASSES_PERIOD']
        format_cs_datetime(enrollment_term['SCHEDULE_OF_CLASSES_PERIOD'], '%Y-%m-%d')
      end
      enrollment_term['TERM_DESCR'] = Berkeley::TermCodes.normalized_english enrollment_term['TERM_DESCR']
      {
        enrollment_term: enrollment_term
      }
    end

    def format_cs_datetime(hash, format)
      if hash['DATETIME']
        hash['DATE'] = format_date strptime_in_time_zone(hash['DATETIME'], format)
        hash.delete 'DATETIME'
      end
    end

    def xml_filename
      'enrollment_term.xml'
    end

    def url
      "#{@settings.base_url}/UC_SR_STDNT_CLASS_ENROLL.v1/Get?EMPLID=#{@campus_solutions_id}&STRM=#{@term_id}"
    end
  end
end
