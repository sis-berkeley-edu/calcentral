module GoogleApps
  class Revoke < Proxy

    include ClassLogger

    def revoke
      unless (access_token = @authorization.access_token)
        logger.error "Nil access_token for #{@uid}; revoking Google OAuth privileges is not possible."
        return false
      end
      @authorization.revoke!
    end

  end
end

