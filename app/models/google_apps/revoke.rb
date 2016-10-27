module GoogleApps
  class Revoke < Proxy

    include ClassLogger

    def revoke
      unless (access_token = @authorization.access_token)
        logger.error "Nil access_token for #{@uid}; revoking Google OAuth privileges is not possible."
        return false
      end
      # Google::APIClient does not implement the token revocation endpoint, so we get it via a regular HTTParty request.
      response = get_response(
        'https://accounts.google.com/o/oauth2/revoke',
        query: {
          token: access_token
        },
        on_error: {
          rescue_status: :all
        }
      )
      if response.code == 200
        logger.warn "Successfully revoked Google access token for user #{@uid}"
        true
      else
        logger.error "Got an error trying to revoke Google access token for user #{@uid}. Status: #{response.code} Body: #{response.body}"
        false
      end
    end

  end
end

