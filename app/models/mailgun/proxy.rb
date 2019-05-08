module Mailgun
  class Proxy < BaseProxy
    include Proxies::Mockable

    def initialize(options = {})
      super(Settings.mailgun_proxy, options)
      @connection = get_connection
      initialize_mocks if @fake
    end

    def get_connection
      Faraday.new do |c|
        c.request :multipart
        c.request :url_encoded
        c.adapter :net_http
        c.basic_auth 'api', @settings.api_key
      end
    end

    def request(options = {})
      url = request_url
      request_method = options.delete :method
      body_options = options.delete(:body) || {}

      logger.info "Fake = #{@fake}; Making request to #{url}"

      response = @connection.send request_method, url, body_options
      logger.debug "Remote server status #{response.status}, Body = #{response.body}"
      response
    end

    def mock_request
      super.merge(uri_matching: request_url)
    end

    def request_url
      [@settings.base_url, @settings.domain, request_path].join '/'
    end
  end
end
