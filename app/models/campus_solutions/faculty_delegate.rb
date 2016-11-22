module CampusSolutions
  class FacultyDelegate < Proxy

    def initialize(options = {})
      super options
      @term_id = options[:term_id]
      @course_id = options[:course_id]
      initialize_mocks if @fake
    end

    def xml_filename
      'faculty_delegate.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      "#{@settings.base_url}/UC_SR_FACULTY_DELEGATE.v1/Get?STRM=#{@term_id}&CLASS_NBR=#{@course_id}"
    end

  end
end
