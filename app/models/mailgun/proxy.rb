module Mailgun
  class Proxy < BaseProxy
    include Proxies::Mockable

    def initialize(options = {})
      super(Settings.mailgun_proxy, options)
      initialize_mocks if @fake
    end

    def request(options = {})
      url = request_url
      logger.info "Fake = #{@fake}; Making request to #{url}"

      body_options = options.delete(:body) || {}
      request_options = {
        basic_auth: {
          username: 'api',
          password: @settings.api_key
        },
        body: body_options,
      }.merge(options)

      response = get_response(url, request_options)
      logger.debug "Remote server status #{response.code}, Body = #{response.body}"
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
