module ClearingHouse
  class MyClearingHouseUrl < UserSpecificModel
    include CampusSolutions::CampusSolutionsIdRequired
    include Proxies::HttpClient
    include ClassLogger

    def initialize(uid, options={})
      super(uid, options)
      @settings = Settings.clearing_house_proxy
      @fake = (options[:fake] != nil) ? options[:fake] : @settings.fake
    end

    def lookup_student_id
      if @uid
        @student_id = User::Identifiers.lookup_campus_solutions_id @uid
      end
    end

    def get_feed_internal
      return {} if @fake
      get_html_response
    end

    def get_html_response
      lookup_student_id
      url = "#{@settings.base_url}"
      options = {
        method: :post,
        headers: {
          "Referer" => 'https://calcentral.berkeley.edu/academics/enrollment_verification',
          "User-Agent" => " "
        },
        body: "user_id=#{@settings.app_id}&password=#{@settings.app_key}&id=#{@student_id}"
      }
      logger.info "get_parsed_response: Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}"
      response = get_response(url, options)
      logger.debug "National Student ClearingHouse remote response: #{response.inspect}"
      response
    end

  end
end
