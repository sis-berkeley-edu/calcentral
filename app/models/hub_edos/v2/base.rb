module HubEdos
  module V2
    class Base < HubEdos::Proxy
      def get_internal(opts = {})
        @campus_solutions_id ||= lookup_campus_solutions_id
        if @campus_solutions_id.nil?
          logger.warn "Lookup of campus_solutions_id for uid #{@uid} failed, cannot call Campus Solutions API"
          {
            feed: empty_feed,
            noStudentId: true
          }
        else
          logger.info "Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
          opts = opts.merge(request_options)
          response = get_response(url, opts)
          logger.debug "Remote server status #{response.code}, Body = #{response.body.force_encoding('UTF-8')}"
          if response.code == 404
            logger.error "Unexpected 404 response for UID #{@uid}, Campus Solutions ID #{@campus_solutions_id}: #{response}"
            feed = empty_feed
          else
            feed = build_feed response
          end
          {
            statusCode: response.code,
            feed: feed,
          }
        end
      end
    end
  end
end
