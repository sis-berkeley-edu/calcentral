class HubEdos::ClassesApi::V1::Feeds::Proxy < ::HubEdos::Proxy
  def get_internal(opts = {})
    logger.info "Fake = #{@fake}; Making request to #{url}; cache expiration #{self.class.expires_in}"
    opts = opts.merge(request_options)
    response = get_response(url, opts)
    logger.debug "Remote server status #{response.code}, Body = #{response.body.force_encoding('UTF-8')}"
    if response.code == 404
      logger.error "Unexpected 404 response for Term ID #{@term_id} and Course ID #{@course_id}: #{response}"
      feed = empty_feed
    else
      feed = build_feed response
    end

    {
      statusCode: response.code,
      feed: feed,
    }
  end

  def settings
    @settings ||= Settings.hub_classes_proxy
  end
end
