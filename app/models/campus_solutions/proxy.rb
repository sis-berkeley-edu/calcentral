module CampusSolutions
  class Proxy < BaseProxy

    include ClassLogger
    include Proxies::MockableXml
    include User::Student

    APP_ID = 'campussolutions'
    APP_NAME = 'Campus Solutions'

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake && xml_filename.present?
    end

    def instance_key
      @uid
    end

    def xml_filename
      ''
    end

    def mock_xml
      read_file('fixtures', 'xml', 'campus_solutions', xml_filename)
    end

    def mock_request
      super.merge(uri_matching: url)
    end

    def get
      return {} unless is_feature_enabled
      wrapped_response = self.class.handling_exceptions(instance_key) do
        get_internal
      end
      if wrapped_response && wrapped_response[:response].is_a?(Hash)
        decorate_internal_response wrapped_response[:response]
      else
        {}
      end
    end

    def get_internal
      if is_cs_id_required?
        @campus_solutions_id = lookup_campus_solutions_id
      end
      if is_cs_id_required? && @campus_solutions_id.nil?
        logger.info "Lookup of campus_solutions_id for uid #{@uid} failed, cannot call Campus Solutions API"
        {
          noStudentId: true
        }
      else
        logger.info "Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}, campus_solutions_id = #{@campus_solutions_id}; cache expiration #{self.class.expires_in}"
        response = get_response(url, request_options)
        logger.debug "Remote server status #{response.code}, Body = #{response.body.force_encoding('UTF-8')}"
        feed = build_feed response
        feed = convert_feed_keys feed
        if is_errored? feed
          logger.error "Error reported in Campus Solutions response (campus_solutions_id=#{@campus_solutions_id}): #{response.inspect}"
          {
            statusCode: 400,
            errored: true,
            feed: feed
          }
        else
          {
            statusCode: response.code,
            feed: feed
          }
        end
      end
    end

    def convert_feed_keys(feed)
      HashConverter.downcase_and_camelize feed
    end

    def decorate_internal_response(response)
      if response[:statusCode] && response[:statusCode] >= 400 && !response[:noStudentId]
        response[:errored] = true
      end
      response
    end

    def error_response_root_xml_node
      'UC_CM_FAULT_DOC'
    end

    def url
      @settings.base_url
    end

    def is_errored?(feed)
      error_key = error_response_root_xml_node.intern
      !feed.is_a?(Hash) || feed[:errmsgtext].present? || feed[error_key].present?
    end

    def request_options
      {
        basic_auth: {
          username: @settings.username,
          password: @settings.password
        }
      }
    end

    def build_feed(response)
      response.parsed_response
    end

    def is_feature_enabled
      true
    end

    def is_cs_id_required?
      false
    end

  end
end
