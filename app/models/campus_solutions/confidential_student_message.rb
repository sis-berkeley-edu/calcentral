module CampusSolutions
  class ConfidentialStudentMessage < GlobalCachedProxy

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def xml_filename
      'confidential_student_message.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      feed = response.parsed_response
      {
        message: feed['ROOT']['GET_MESSAGE_CAT_DEFN']['DESCRLONG'].strip
      }
    end

    def url
      "#{@settings.base_url}/UC_CC_MESSAGE_CATALOG.v1/get?MESSAGE_SET_NBR=28000&MESSAGE_NBR=52"
    end

  end
end
